module "jenkins_server" {
    source = "./modules/jenkins_server"
    amiid = var.amiid
    instance_type = var.instance_type
    keyname = var.keyname
}