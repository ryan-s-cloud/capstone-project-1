variable "controller_ips" {
  type = list(string)

  default = [
    "10.240.0.10"
  ]
}

variable "worker_ips" {
  type = list(string)

  default = [
    "10.240.0.20",
    "10.240.0.21"
  ]
}

variable "worker_pod_cidrs" {
  type = list(string)

  default = [
    "10.200.0.0/24",
    "10.200.1.0/24"
  ]
}

variable "PUBLIC_KEY_PATH" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "PRIV_KEY_PATH" {
  type = string
  default = "~/.ssh/id_rsa"
}
