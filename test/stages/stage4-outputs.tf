
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.cp4d-instance.name
        branch      = module.cp4d-instance.branch
        namespace   = module.cp4d-instance.namespace
        server_name = module.cp4d-instance.server_name
        layer       = module.cp4d-instance.layer
        layer_dir   = module.cp4d-instance.layer == "infrastructure" ? "1-infrastructure" : (module.cp4d-instance.layer == "services" ? "2-services" : "3-applications")
        type        = module.cp4d-instance.type
      })
    }
  }
}
