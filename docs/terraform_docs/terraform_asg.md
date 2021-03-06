# ASG

## Creating the config
ASG configuration will determine what type of EC2 instances we want our ASG to spin up. This will determine the instance types, image ids, security groups, user data, and iam instance profile.

```
resource "aws_launch_configuration" "asg_conf" {
  name_prefix = "terraform-"
  image_id      = "ami-03705bf93ac3a378e"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.web_sg.id}"]
  user_data = "${file("../cloud-init.conf")}"
  iam_instance_profile = "${data.terraform_remote_state.circleci.ec2-get-iam-role}"

  lifecycle {
    create_before_destroy = true
  }
}
```

## ASG setup
The aws_autoscaling_group resource will determine the desired number of EC2 instances to spin up and the maximum amount if more are needed. It will determine the type of health check to perform on our instances and which launch configuration to attach. It will set the subnets we wish to run the instances in and will also attach our ALB target group.

```
resource "aws_autoscaling_group" "asg" {
  name                      = "asg-matabit"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.asg_conf.name}"
  vpc_zone_identifier       = ["${data.terraform_remote_state.vpc.aws_subnet_private_a_id}", "${data.terraform_remote_state.vpc.aws_subnet_private_b_id}"]
  target_group_arns         = ["${aws_alb_target_group.alb_target_group.arn}"]
  wait_for_capacity_timeout = "15m"
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn   = "${aws_alb_target_group.alb_target_group.arn}"
}
```

## ASG schedule
In addition, we setup a schedule in our ASG so that our instances will spin up every day at 7 am and will be terminated at 1 am. Times are in UTC.

```
resource "aws_autoscaling_schedule" "asg_schedule_on" {
  scheduled_action_name  = "asg_on"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 2
  recurrence             = "0 13 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_schedule" "asg_schedule_off" {
  scheduled_action_name  = "asg_off"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 8 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}
```