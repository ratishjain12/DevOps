variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "node_app_port" {
  type    = number
  default = 3000
}

variable "elastic_search_port" {
  type    = number
  default = 9200
}

variable "logstash_port" {
  type    = number
  default = 5044
}

variable "kibana_port" {
  type    = number
  default = 5601
}