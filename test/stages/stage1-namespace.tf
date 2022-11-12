# module "gitops_namespace" {
#   source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

#   gitops_config = module.gitops.gitops_config
#   git_credentials = module.gitops.git_credentials
#   name = var.namespace
#   create_operator_group = false
# }

module "gitops_cs_namespace" {
  depends_on = [
    module.dev_tools_namespace
  ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = var.cpd_common_services_namespace
  create_operator_group = false
}

module "gitops_cpd_operator_namespace" {
  depends_on = [
    module.gitops_cs_namespace
  ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = var.cpd_operator_namespace
  create_operator_group = true
}


resource null_resource write_namespace {
  provisioner "local-exec" {
    command = "echo -n '${module.dev_tools_namespace.name}' > .namespace"
  }
  provisioner "local-exec" {
    command = "echo -n '${module.gitops_cs_namespace.name}' > .cs_namespace"
  }
  provisioner "local-exec" {
    command = "echo -n '${module.gitops_cpd_operator_namespace.name}' > .operator_namespace"
  }
}


