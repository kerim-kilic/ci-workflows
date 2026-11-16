# Smallest configuration that every check can run against: no providers, so it initialises and validates offline.
terraform {
  required_version = ">= 1.11.0"
}

variable "name" {
  description = "Name to greet."
  type        = string
  default     = "fixture"
}

output "greeting" {
  description = "A greeting, so the module has an output."
  value       = "Hello, ${var.name}"
}
