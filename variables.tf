variable "tags_cloudguard" {
  type        = map(any)
  description = "CloudGuard tags values"
  default = {
    "fusion_inventory" = "TRUE"
  }
}

variable "resource_group_name" {
  type        = string
  description = "Target resource group name"
}

variable "index" {
  type        = number
  description = "Index of the VM"
  validation {
    condition     = var.index >= 1 && var.index <= 999 && floor(var.index) == var.index
    error_message = "Valid values for var: index are (between 1 to 999)."
  }
}

variable "size" {
  type        = string
  description = "VM size (https://docs.microsoft.com/en-us/azure/virtual-machines/sizes)."
}

variable "os_type" {
  type        = string
  description = "VM OS type => Windows, Linux"
  validation {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "Valid values for var: os_type are (Windows, Linux)."
  }
}

variable "data_disk" {
  type = map(object({
    size = number
    type = string
    lun  = number
  }))
  description = "Map of data disk(s)"
  default     = {}
}

variable "os_disk_type" {
  type        = string
  description = "VM OS disk type => Premium_LRS, Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_ZRS"
  default     = "Standard_LRS"
  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.os_disk_type)
    error_message = "Valid values for var: os_disk_type are (Premium_LRS, Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_ZRS)."
  }
}

variable "role" {
  type        = string
  description = "VM role => frontend, backend, etc..."
}

variable "classification" {
  type        = string
  description = "VM classification => application [app] or infrastructure [infra]"
  default     = "app"
  validation {
    condition     = contains(["app", "infra"], var.classification)
    error_message = "Valid values for var: classification are (app, infra)."
  }
}

variable "availability" {
  type        = string
  description = "VM desired availability => 24/24 - 7/7, businessday, self-care, sleep"
  default     = "businessday"
  validation {
    condition     = contains(["24/24 - 7/7", "businessday", "self-care", "sleep"], var.availability)
    error_message = "Valid values for var: availability are (24/24 - 7/7, businessday, self-care, sleep)."
  }
}

variable "reboot_hebdo" {
  type        = bool
  description = "Allow downtime for maintenance and update"
  default     = false
}

variable "backup" {
  type        = string
  description = "Add VM on  backup"
  default     = "false"
  validation {
    condition     = contains(["false", "true"], var.backup)
    error_message = "Valid values for var: backup are (true, false)."
  }
}

# Parts to generate for cloud init
variable "cloudinit_parts" {
  description = <<EOF
(Optional) A list of maps that contain the information for each part in the cloud-init configuration.
Each map should have the following fields:
* content-type - type of content for this part, e.g. text/x-shellscript => https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config#content_type
* filepath - path to the file to use as a template
* vars - map of variables to use with the part template
  EOF

  type = list(object({
      content-type = string
      filepath =  string
      vars = map(string)
  }))
  default = []
}

locals {
  validate_os_disk_type = length(regexall("[^.].*[sS].*", var.size)) == 0 ? contains(["Standard_LRS", "StandardSSD_LRS", "StandardSSD_ZRS"], var.os_disk_type) ? "isOK" : tobool("Requested operation cannot be performed because the VM size (${var.size}) does not support the storage account type ${var.os_disk_type}. Consider updating the VM to a size that supports Premium storage.") : "isOK"
  validate_data_disk    = [for disk in var.data_disk : length(regexall("[^.].*[sS].*", var.size)) == 0 ? contains(["Standard_LRS", "StandardSSD_LRS", "StandardSSD_ZRS"], disk.type) ? "isOK" : tobool("Requested operation cannot be performed because the VM size (${var.size}) does not support the storage account type ${disk.type}. Consider updating the VM to a size that supports Premium storage.") : "isOK"]
}