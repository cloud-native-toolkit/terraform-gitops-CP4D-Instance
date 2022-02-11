locals {
  name          = "cp4d-instance"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  values_content = {
    cp4d_namespace = var.namespace
    cp4d_instance_name = var.cp4d_instance_name
    cpd_operator_namespace = var.cpd_operator_namespace
    license_accept = var.license_accept
    license = var.license_type
    storage_vendor = var.storage_vendor
  }
  layer = "services"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

# module pull_secret {
#   source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

#   gitops_config = var.gitops_config
#   git_credentials = var.git_credentials
#   server_name = var.server_name
#   kubeseal_cert = var.kubeseal_cert
#   namespace = var.namespace
#   docker_username = "cp"
#   docker_password = var.entitlement_key
#   docker_server   = "cp.icr.io"
#   secret_name     = "ibm-entitlement-key-s"
# }

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}' --type '${local.type}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(nonsensitive(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}
