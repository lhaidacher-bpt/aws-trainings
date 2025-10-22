resource "aws_appflow_flow" "this" {
  name        = var.name
  description = "S3 to Salesforce via AppFlow"

  trigger_config {
    trigger_type = "Scheduled"

    trigger_properties {
      scheduled {
        schedule_expression = var.schedule_expression
        data_pull_mode = "Incremental"
      }
    }
  }

  source_flow_config {
    connector_type = "S3"

    source_connector_properties {
      s3 {
        bucket_name   = var.bucket_name
        bucket_prefix = var.bucket_prefix

        s3_input_format_config {
          s3_input_file_type = "JSON"
        }
      }
    }
  }

  destination_flow_config {
    connector_type         = "Salesforce"
    connector_profile_name = var.connector_profile_name

    destination_connector_properties {
      salesforce {
        object               = var.salesforce_object
        write_operation_type = "UPSERT"
        id_field_names       = [var.dest_field_id]

        error_handling_config {
          fail_on_first_destination_error = false
        }
      }
    }
  }

  task {
    task_type         = "Map"
    source_fields     = ["id"]
    destination_field = var.dest_field_id
    task_properties = {}

    connector_operator {
      s3 = "NO_OP"
    }
  }

  task {
    task_type         = "Map"
    source_fields     = ["vorname"]
    destination_field = var.dest_field_vorname
    task_properties = {}

    connector_operator {
      s3 = "NO_OP"
    }
  }

  task {
    task_type         = "Map"
    source_fields     = ["nachname"]
    destination_field = var.dest_field_nachname
    task_properties = {}

    connector_operator {
      s3 = "NO_OP"
    }
  }

  task {
    task_type     = "Filter"
    source_fields = ["id", "vorname", "nachname"]
    task_properties = {}

    connector_operator {
      s3 = "PROJECTION"
    }
  }

  tags = var.tags
}

data "aws_iam_policy_document" "s3_source" {
  statement {
    sid    = "AllowAppFlowSourceActions"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["appflow.amazonaws.com"]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_source" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.s3_source.json
}
