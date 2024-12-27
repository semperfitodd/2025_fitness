locals {
  environment = replace(var.environment, "_", "-")
}

variable "domain" {
  description = "Base domain for the website"
  type        = string

  default = null
}

variable "environment" {
  description = "Environment name"
  type        = string

  default = null
}

variable "region" {
  description = "AWS region"
  type        = string

  default = null
}

variable "tags" {
  description = "Universal tags"
  type        = map(string)

  default = {}
}

