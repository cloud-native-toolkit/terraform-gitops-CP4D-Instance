
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}


variable cp4d_instance_name {
  type = string
  description = "CP4D instance name.  Default is ibmcpd-cr"
  default = "ibmcpd-cr"
}

variable license_accept {
  type = bool
  description = "License acceptance"
  default = "true"
}
variable license_type {
  type = string
  description = "License type (Enterprise | Standard)"
  default = "Enterprise"
}

variable "storage_vendor" {
  type = string
  description = "Storage vendor for CPD (ocs | portworx | ibm-spectrum-scale-sc | RWX-storage-class)"
  default = "portworx"
}

# variable "entitlement_key" {
#   type        = string
#   description = "The entitlement key required to access Cloud Pak images"
#   sensitive   = true
# }