variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "volume_size" {
  type        = number
  default     = 30
  description = "Size of the EBS volume for Elasticsearch data in GB"
}

variable "instance_type" {
  type    = string
  default = "t3.large"
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