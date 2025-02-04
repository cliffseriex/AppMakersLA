output "s3_website_url" {
  description = "The S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "cloudfront_url" {
  description = "The CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}
