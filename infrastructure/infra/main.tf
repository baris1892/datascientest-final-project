module "argocd" {
  source = "./modules/argocd"
}

module "cert-manager" {
  source = "./modules/cert-manager"
}

module "mailpit" {
  source               = "./modules/mailpit"
  monitoring_namespace = module.monitoring.monitoring_namespace_name
}

module "monitoring" {
  source = "./modules/monitoring"
}

module "networking" {
  source = "./modules/networking"
}
