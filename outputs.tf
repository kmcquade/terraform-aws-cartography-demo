output "public_ip" {
  description = "The public IP address of the EC2 instance running Cartography."
  value       = module.cartography_instance.public_ip
}

//output "zREADME" {
//  value = <<-README
//
//  * Add your SSH key to the ssh-agent, if you haven't already
//  ssh-add /path/to/your/ssh/key.pem
//
//  * SSH into the instance
//  ssh -A ec2-user@$${module.cartography_instance.public_ip}
//
//  * Keep in mind that the installation stuff will take a while. You can tail the logs in `/var/log/cloud-init-output.log` to see when the user-data installation script is complete.
//
//  * Install cartography as the Ec2 user
//  pip3 install --user cartography
//
//  * Initialize cartography
//  cartography --neo4j-uri bolt://$${module.cartography_instance.public_ip}:7687
//
//  * Visit the following URL in your browser: http://$${module.cartography_instance.public_ip}:7474
//
//  * It will bring you to the Neo4j database login. Enter `neo4j` as both your username and your password. Enjoy!
//README
//}

output "zREADME" {
  description = "Post-deploy instructions"
  value       = <<-README

  * Keep in mind that the installation stuff will take a while.
  * You can ssh into the instance and tail the logs in `/var/log/cloud-init-output.log` to see when the user-data installation script is complete.
  * Visit the following URL in your browser: http://$${module.cartography_instance.public_ip}:7474
  * It will bring you to the Neo4j database login. Enter `neo4j` as both your username and your password. Enjoy!
README
}

output "root_block_device_volume_ids" {
  value       = module.cartography_instance.root_block_device_volume_ids
  description = "List of volume IDs of root block devices of instances"
}

output "bucket" {
  description = "The name of the S3 bucket"
  value       = module.s3_bucket.bucket_id
}

output "bucket_config_path" {
  description = "The path to the cartography cross account config stashed in s3"
  value       = "s3://${aws_s3_bucket_object.cartography_config.bucket}/${aws_s3_bucket_object.cartography_config.key}"
}