resource "aws_dynamodb_table" "raw_data" {
  name         = "${var.environment}_raw_data"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "date"
    type = "S"
  }

  attribute {
    name = "exercise"
    type = "S"
  }

  hash_key  = "date"
  range_key = "exercise"

  global_secondary_index {
    name            = "exercise-date-index"
    hash_key        = "exercise"
    range_key       = "date"
    projection_type = "ALL"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = var.tags
}

resource "aws_dynamodb_table" "aggregates" {
  name         = "${var.environment}_aggregated"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "exercise_name"
    type = "S"
  }

  hash_key = "exercise_name"

  tags = var.tags
}
