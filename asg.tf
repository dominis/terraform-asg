resource "aws_launch_configuration" "launch_config" {
  name_prefix = "${var.name}-"

  image_id        = "${var.ami_id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.dummy.key_name}"
  security_groups = ["${aws_security_group.asg-node.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudformation_stack" "autoscaling_group" {
  name       = "${var.name}"
  depends_on = ["aws_launch_configuration.launch_config"]

  template_body = <<EOF
{
  "Resources": {
    "Asg": {
      "Type": "AWS::AutoScaling::AutoScalingGroup",
      "Properties": {
        "AvailabilityZones": ["${join(", ", formatlist("\\"%s\\"", split(",", var.availability_zones)))}"],
        "VPCZoneIdentifier": ["${join(", ", formatlist("\\"%s\\"", split(",", var.private_subnets)))}"],
        "LaunchConfigurationName": "${aws_launch_configuration.launch_config.name}",
        "MaxSize": "${var.maximum_number_of_instances}",
        "MinSize": "${var.minimum_number_of_instances}",
        "DesiredCapacity": "${var.number_of_instances}",
        "LoadBalancerNames": ["${aws_elb.asg-elb.name}"],
        "TerminationPolicies": ["OldestLaunchConfiguration", "OldestInstance"],
        "HealthCheckType": "EC2",
        "HealthCheckGracePeriod": 30,
        "Tags" : [{
          "Key" : "Name",
          "Value" : "${var.name}",
          "PropagateAtLaunch" : "true"
        }]
      },
      "UpdatePolicy": {
        "AutoScalingRollingUpdate": {
          "MinInstancesInService": "${var.minimum_number_of_instances}",
          "MaxBatchSize": "${var.rolling_update_batch_size}",
          "PauseTime": "PT0S"
        }
      }
    }
  }
},
  "Outputs": {
    "AsgName": {
      "Description": "The name of the auto scaling group",
       "Value": {"Ref": "Asg"}
    }
  }
}
EOF
}

resource "aws_autoscaling_policy" "policy" {
  name                   = "${var.name}"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 90
  autoscaling_group_name = "${aws_cloudformation_stack.autoscaling_group.outputs.AsgName}"
}

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  alarm_name          = "${var.name}-cpu-watch"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions {
    AutoScalingGroupName = "${aws_cloudformation_stack.autoscaling_group.outputs.AsgName}"
  }

  alarm_description = "node cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.policy.arn}"]
}
