variable "bucket_name" {
  description = "The name of the S3 bucket for the frontend"
  type        = string
}

variable "environment" {
  description = "Environment name (staging, production, etc.)"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket for frontend files"
  type        = string
}

variable "source_path" {
  description = "Path to the frontend zip file"
  type        = string
}

variable "mime_types" {
  description = "Mapping of file extensions to MIME types"
  type        = map(string)
  default = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".json" = "application/json"
  }
}
