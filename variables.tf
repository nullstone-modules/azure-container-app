variable "location" {
  type        = string
  description = "Azure region to deploy resources."
}

variable "cpu" {
  type        = number
  default     = 0.5
  description = <<EOF
The amount of CPU to allocate to the container app.
Supported values: 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0.
EOF
}

variable "memory" {
  type        = string
  default     = "1Gi"
  description = <<EOF
The amount of memory to allocate to the container app.
Must be in the format "{number}Gi". The amount of memory must correspond to the CPU allocation.
EOF
}

variable "command" {
  type        = list(string)
  default     = []
  description = <<EOF
This overrides the `CMD` specified in the image.
Specify a blank list to use the image's `CMD`.
EOF
}

variable "min_replicas" {
  type        = number
  default     = 0
  description = "Minimum number of container replicas. Set to 0 for scale-to-zero."
}

variable "max_replicas" {
  type        = number
  default     = 5
  description = "Maximum number of container replicas."
}

variable "container_port" {
  type        = number
  default     = 8080
  description = "The port that the container listens on for incoming HTTP traffic."
}

variable "image_url" {
  type    = string
  default = ""

  description = <<EOF
This allows you to override the image used for the application.
If blank, Nullstone will create an image repository and provide management of images.
If you configure image_url, you can still use `nullstone deploy --version=<...>` to deploy a specific image tag.
EOF
}
