resource "aws_cloudfront_distribution" "distribution" {
  comment = "[${var.stage_slug}] gold-price-tracker-api origin"
  enabled = true

  is_ipv6_enabled = true

  # Only serve in US/EU
  price_class = "PriceClass_100"

  # No restrictions for incoming traffic
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Connect to the ALB
  origin {
    domain_name = aws_alb.this.dns_name
    origin_id   = "${var.stage_slug}-origin-id"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = [
        "TLSv1.2"
      ]
    }
  }

  # DISABLE ALL CACHE
  # @see Managed-CachingDisabled
  default_cache_behavior {

    # methods to forward to the server
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]

    # methods to cache
    # this is mandatory, cloudfront wont cache them if properly set
    cached_methods = [
      "HEAD",
      "GET"
    ]

    # A unique identifier for the origin
    target_origin_id = "${var.stage_slug}-origin-id"

    # Dont allow HTTP - always redirect to HTTPS
    viewer_protocol_policy = "redirect-to-https"

    # The server should already have this compressed the response
    # compress = false

    # Disable cache on all objects
    default_ttl = 0
    min_ttl     = 0
    max_ttl     = 0

    forwarded_values {
      cookies {
        forward = "all"
      }
      headers = [
        "*"
      ]
      query_string = true
    }
  }

  # Serve the content with HTTPS
  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
  }

  tags = {
    Stage = var.stage_slug
  }
}
