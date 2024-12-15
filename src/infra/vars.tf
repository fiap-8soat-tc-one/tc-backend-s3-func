variable "region" {
  description = "region"
  type        = string
  default     = "us-east-1"
}


variable "backend_url" {
  description = "backend url"
  type        = string
  default     = "http://a3fdeabc4b7b54d08bec2b5d850b1bc7-1605196733.us-east-1.elb.amazonaws.com/api"
}
