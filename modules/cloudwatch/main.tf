# SNS Topic for alerts
# SNS = Simple Notification Service
# Sends emails when alarm triggers
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Name        = "${var.project_name}-${var.environment}-alerts"
    Environment = var.environment
  }
}

# Subscribe email to SNS topic
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# EC2 CPU Alarm
# Triggers when CPU > threshold
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  count = length(var.ec2_instance_ids)

  alarm_name          = "${var.project_name}-${var.environment}-ec2-cpu-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "EC2 CPU usage is too high!"

  dimensions = {
    InstanceId = var.ec2_instance_ids[count.index]
  }

  # What to do when alarm triggers
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
  }
}

# EC2 Status Check Alarm
# Triggers when EC2 instance fails
resource "aws_cloudwatch_metric_alarm" "ec2_status" {
  count = length(var.ec2_instance_ids)

  alarm_name          = "${var.project_name}-${var.environment}-ec2-status-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "EC2 instance status check failed!"

  dimensions = {
    InstanceId = var.ec2_instance_ids[count.index]
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
  }
}

# RDS CPU Alarm
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 120
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "RDS CPU usage is too high!"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
  }
}

# RDS Free Storage Alarm
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 120
  statistic           = "Average"
  threshold           = 5000000000   # 5GB in bytes
  alarm_description   = "RDS storage is running low!"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
  }
}

# ALB Unhealthy Hosts Alarm
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets!"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment
  }
}

# CloudWatch Dashboard
# Visual overview of all metrics
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "EC2 CPU Utilization"
          metrics = [
            ["AWS/EC2", "CPUUtilization",
             "InstanceId", var.ec2_instance_ids[0]]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "RDS CPU Utilization"
          metrics = [
            ["AWS/RDS", "CPUUtilization",
             "DBInstanceIdentifier", var.rds_instance_id]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ALB Healthy Hosts"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount",
             "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 60
          stat   = "Maximum"
          region = "us-east-1"
        }
      }
    ]
  })
}