variable "vault" {
  description = "describes key vault related configuration"
  type        = any
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}
