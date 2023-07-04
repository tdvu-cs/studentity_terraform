variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
  default     = "studentity-372802"
}

variable "region" {
  description = "The region where the resources will be created."
  type        = string
  default     = "australia-southeast1"
}

variable "zone" {
  description = "The zone where the resources will be created."
  type        = string
  default     = "australia-southeast1-b"
}

variable "credentials" {
  type    = string
  default = "credentials.json"
}