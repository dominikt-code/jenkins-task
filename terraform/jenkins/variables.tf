variable "my_ip_cidr" {
  description = "Your IP to get to Jenkins"
  type        = string
  default     = "37.47.236.133/32" # curl -s ifconfig.me
}
