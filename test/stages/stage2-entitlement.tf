module "global_sealed_secrets" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-global-pullsecret"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert

  docker_server = "cp.icr.io"
  docker_username = "cp"
  secret_name = "cp4d-entitlement-key"
  docker_password = var.cp_entitlement_key
}


module "gitops_global_pullsecret_synch" {
  depends_on = [
    module.global_sealed_secrets
  ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-global-pullsecret-synch"

  git_credentials = module.gitops_repo.git_credentials
  gitops_config = module.gitops_repo.gitops_config
  kubeseal_cert = module.gitops_repo.sealed_secrets_cert
  namespace = module.gitops_namespace.name
  server_name = module.gitops_repo.server_name
}