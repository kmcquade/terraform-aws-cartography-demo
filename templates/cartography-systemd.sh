#!/usr/bin/env bash
set -x
# ---------------------------------------------------------------------------------------------------------------------
# Filter out useless messages from logs
# ---------------------------------------------------------------------------------------------------------------------
cat <<EOF > /etc/rsyslog.d/01_filters.conf

if \$programname == 'systemd' and \$msg contains "Started Session" then stop
if \$programname == 'systemd' and \$msg contains "Starting Session" then stop
if \$programname == 'systemd' and \$msg contains "Created slice" then stop
if \$programname == 'systemd' and \$msg contains "Starting user-" then stop
if \$programname == 'systemd' and \$msg contains "Stopping user-" then stop
if \$programname == 'systemd' and \$msg contains "Removed slice" then stop
EOF
systemctl restart rsyslog

# ---------------------------------------------------------------------------------------------------------------------
# Prereqs
# ---------------------------------------------------------------------------------------------------------------------
yum -y install git python3 python3-pip

# ---------------------------------------------------------------------------------------------------------------------
# Neo4j installation
# ---------------------------------------------------------------------------------------------------------------------

# Follow Neo4j instructions for installation, per https://yum.neo4j.org/stable/
cd /tmp
wget http://debian.neo4j.org/neotechnology.gpg.key
rpm --import neotechnology.gpg.key

cat <<EOF > /etc/yum.repos.d/neo4j.repo
[neo4j]
name=Neo4j Yum Repo
baseurl=http://yum.neo4j.org/stable
enabled=1
gpgcheck=1
EOF

yum -y install neo4j

### Neo4j config
cat << EOF > /etc/neo4j/neo4j.conf
${neo4j_config}
EOF

chown -R neo4j:neo4j /var/log/neo4j
chown -R neo4j:neo4j /var/lib/neo4j/data/databases
chown -R neo4j:neo4j /var/lib/neo4j/certificates

systemctl enable neo4j
systemctl start neo4j

### Restart it because it keeps throwing random errors
killall -9 java
systemctl restart neo4j

# ---------------------------------------------------------------------------------------------------------------------
# Cartography installation
# ---------------------------------------------------------------------------------------------------------------------

#### User specific installation
# Create a dedicated service user
useradd -r -s /bin/false ${cartography_user}
groupadd ${cartography_user}
# Add users to the cartography group
usermod -aG ${cartography_user} cartography
# This one is necessary so the systemd service can start cartography
usermod -aG ${cartography_user} root

#### Download Cartography version and unzip
yum -y install unzip
wget https://github.com/lyft/cartography/archive/${cartography_version}.zip
unzip ${cartography_version}.zip
mkdir -p /opt/cartography
unzip ${cartography_version}.zip -d /opt/cartography/
mv /opt/cartography/cartography-${cartography_version}/* /opt/cartography
rm -rf /opt/cartography/cartography-${cartography_version}/

#### Cartography installation
# Set up a new Virtualenv in the cartography directory
python3 -m venv /opt/cartography/venv
# Activate the virtualenv
source /opt/cartography/venv/bin/activate
# Make sure the cartography user owns it, not root
chown -R ${cartography_user}:${cartography_user} /opt/cartography
# Install it
/opt/cartography/venv/bin/python3 /opt/cartography/setup.py install
# Since the setup ran as root, just chown it again so the cartography user owns it
chown -R ${cartography_user}:${cartography_user} /opt/cartography

# ---------------------------------------------------------------------------------------------------------------------
# Cartography systemd service setup
# ---------------------------------------------------------------------------------------------------------------------
# Set up the environments file
# NOTE: Do NOT use this method in production.
# Run Neo4j in docker and then load the secrets as environment variables with Secrets Manager in ECS or something.
#environment_file="/opt/cartography/etc/cartography.d/cartography.sh"
mkdir -p /opt/cartography/etc/cartography.d/
cat <<EOF > ${environment_file}
PYTHONPATH=/opt/cartography/venv/lib/python3.7/site-packages/
NEO4J_PASSWORD_ENV_VAR=neo4j
NEO4J_USER=neo4j
PYTHONUNBUFFERED=1
AWS_CONFIG_FILE=/home/${cartography_user}/.aws/config
EOF

chmod 754 ${environment_file}
# Chown for the environment file and the directories leading to it
chown -R ${cartography_user}:${cartography_user} /opt/cartography

cat <<EOF > /etc/systemd/system/cartography.service
[Unit]
Description=Cartography
Documentation=https://github.com/lyft/cartography
Requires=network-online.target neo4j.service
After=network-online.target neo4j.service
Wants=cartography-refresh.timer

[Service]
ExecStart=/opt/cartography/venv/bin/python3 -m cartography --neo4j-uri bolt://localhost:7687 --aws-sync-all-profiles
WorkingDirectory=/opt/cartography/
User=cartography
Group=cartography
KillMode=process
KillSignal=SIGTERM
EnvironmentFile=/opt/cartography/etc/cartography.d/cartography.sh
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Change permissions on service file
chown root:root /etc/systemd/system/cartography.service
chmod 644 /etc/systemd/system/cartography.service
# Make sure it is listed
systemctl list-unit-files | grep cartography.service
# Enable the service and create the symlink in /usr/lib
systemctl enable cartography

# ---------------------------------------------------------------------------------------------------------------------
# Cartography AWS Configuration
# ---------------------------------------------------------------------------------------------------------------------
# TODO: Change the AWS config file to match the following:

#[account-alias]
#role_arn = arn:aws:iam::123456789012:role/role-name
#credential_source = Ec2InstanceMetadata

# ^^ this kind of depends on whether or not we'd use Gossamer to refresh the credentials,
# and if so, if we'd use the credentials file to populate the config file.

# Make sure the cartography user can read from the credentials file
mkdir -p /home/${cartography_user}/.aws/
aws s3 cp ${aws_config_s3_path} /home/${cartography_user}/.aws/config
#cat << 'eof' >> /home/${cartography_user}/.aws/config
#[default]
#region = us-east-1
#output=json
#eof

chown -R ${cartography_user}:${cartography_user} /home/${cartography_user}/.aws/

# ---------------------------------------------------------------------------------------------------------------------
# Temporary fix for cartography to get around Okta error
# Make adjustment until https://github.com/lyft/cartography/pull/216 is fixed
# ---------------------------------------------------------------------------------------------------------------------
#sed -i "s/if not config.okta_api_key/if 'okta_api_key' not in config/g" /opt/cartography/cartography/intel/okta/__init__.py
sed -i "s/route53.sync(neo4j_session, boto3_session, account_id, sync_tag)//g" /opt/cartography/cartography/intel/aws/__init__.py
sed -i "s/elasticsearch.sync(neo4j_session, boto3_session, account_id, sync_tag)//g" /opt/cartography/cartography/intel/aws/__init__.py
sed -i "s/run_cleanup_job('aws_account_dns_cleanup.json', neo4j_session, common_job_parameters)//g" /opt/cartography/cartography/intel/aws/__init__.py
# Until this is merged - https://github.com/lyft/cartography/pull/221/files
#sed -i "s/instance.region = {Region}, instance.lastupdated = {aws_update_tag}/instance.region = {Region}, instance.lastupdated = {aws_update_tag}, instance.iaminstanceprofile = {IamInstanceProfile}/g" /opt/cartography/cartography/intel/aws/ec2.py
#sed -i "s/instance.region = {Region}, instance.lastupdated = {aws_update_tag}/instance.region = {Region}, instance.lastupdated = {aws_update_tag}, instance.iaminstanceprofile = {IamInstanceProfile}/g" /opt/cartography/cartography/intel/aws/ec2.py

# ---------------------------------------------------------------------------------------------------------------------
# Refresh cartography every X minutes. Might be too much
# ---------------------------------------------------------------------------------------------------------------------
cat << 'eof' >> /etc/systemd/system/cartography-refresh.timer
[Unit]
Description=Cartography refresh every 24 hours
Requires=cartography.service

[Timer]
Unit=cartography.service
OnUnitInactiveSec=9880m
RandomizedDelaySec=15m
AccuracySec=1s

[Install]
WantedBy=timers.target
eof

rm -f /opt/cartography/cartography/intel/aws/ec2.py
wget "https://gist.githubusercontent.com/kmcquade/9bbda31d33d817bbcaece3ec6809e51d/raw/7f3e70833e7d6f0b2237cbde74a5ed90a11c720a/ec2.py" -O /opt/cartography/cartography/intel/aws/ec2.py
chown cartography:cartography /opt/cartography/cartography/intel/aws/ec2.py

systemctl daemon-reload
#systemctl enable cartography-refresh.timer
systemctl list-timers --all
#systemctl start cartography-refresh.timer

systemctl start cartography
