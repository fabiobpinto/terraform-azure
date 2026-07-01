variable "route_table_name" {
  description = "The name of the virtual hub route table."
  type        = string
}

variable "route_table_labels" {
  description = "A list of labels to assign to the virtual hub route table."
  type        = list(string)
  default     = []
}

variable "virtual_hub_id" {
  description = "The ID of the virtual hub to which the route table belongs."
  type        = string
}

variable "routes" {
  description = "A list of route objects to define the routes in the virtual hub route table."
  type = list(object({
    name              = string
    destinations_type = string
    destinations      = list(string)
    next_hop_type     = string
    next_hop          = string
  }))
  default = []
}
