variable "my_ip_cidr" {
  description = "Your IP to get to Jenkins"
  type        = string
  default     = "37.47.194.228/32" # curl -s ifconfig.me
}
