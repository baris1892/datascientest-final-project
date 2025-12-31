variable "namespace" {
  type = string
}

variable "frontend_values" {
  type = list(string)
}

variable "backend_values" {
  type = list(string)
}

variable "database_values_file" {
  type = string
}

variable "database_secrets" {
  type = any
}
