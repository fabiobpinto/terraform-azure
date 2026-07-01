variable "vhub_connection_name" {
  description = "Virtual Hub Connection name"
  type        = string
}

variable "virtual_hub_id" {
  description = "Virtual Hub ID to which the Virtual Hub Connection will be associated"
  type        = string
}

variable "remote_virtual_network_id" {
  description = "Remote Virtual Network ID to which the Virtual Hub Connection will be associated"
  type        = string
}
