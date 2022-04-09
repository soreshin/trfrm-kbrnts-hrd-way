variable "yc_token" {
  type      = string
  sensitive = true
}

variable "yc_zone" {
  type  = string
  default = "ru-central1-a"
}

variable "yc_project" {
  type = object({
    cloud_id  = string
    folder_id = string
  })
}

variable "ssh_public_key" {
  type = string
  sensitive = true
}