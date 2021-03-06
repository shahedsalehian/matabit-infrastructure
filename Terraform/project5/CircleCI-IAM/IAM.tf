terraform {
  backend "s3" {
    bucket         = "matabit-terraform-state-bucket"
    region         = "us-west-2"
    dynamodb_table = "matabit-terraform-statelock"
    key            = "circle-ci-iam/s3.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

/* Circle CI User/Group */
resource "aws_iam_user" "circleci" {
  name = "circleci"
}

resource "aws_iam_group" "circleci" {
  name = "circleci"
}

resource "aws_iam_group_membership" "circleci" {
  name  = "circleci"
  users = ["${aws_iam_user.circleci.id}"]
  group = "${aws_iam_group.circleci.name}"
}

/* IAM Policies */
resource "aws_iam_group_policy" "circle-ci-put" {
  name  = "circle-ci-put"
  group = "${aws_iam_group.circleci.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:ListBucket"
            ],
            "Resource": [
              "arn:aws:s3:::*/*",
              "arn:aws:s3:::matabit.org",
              "arn:aws:s3:::matabit.org/*"
              ]
        }
    ]
}
EOF
}