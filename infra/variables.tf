variable "project_id" {
  type = string
}

variable "repository_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "api_key" {
  type        = string
  description = "API key for this project (remove if this is a public app)"
}