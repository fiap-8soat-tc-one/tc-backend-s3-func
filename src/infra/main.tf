provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "fiap-2bdc9c48"
    key    = "terraform/states/rds.tfstate"
    region = "us-east-1"
  }
}

resource "aws_cloudformation_stack" "example_stack" {
  name          = "ExampleCloudFormationStack"
  template_body = <<TEMPLATE
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Transform": "AWS::Serverless-2016-10-31",
  "Description": "generate-token-app\n\nSample SAM Template for generate-token-app",
  "Globals": {
    "Function": {
      "Timeout": 3
    }
  },
  "Resources": {
    "BasicAWSApiGateway": {
      "Type": "AWS::Serverless::Api",
      "Properties": {
        "Name": "Basic AWS Api Gateway",
        "StageName": "Staging"
      }
    },
    "GenerateTokenFunction": {
      "Type": "AWS::Serverless::Function",
      "Properties": {
        "CodeUri": "../generate-token",
        "Handler": "main",
        "Runtime": "go1.x",
        "Architectures": [
          "x86_64"
        ],
        "Events": {
          "GenerateTokenApi": {
            "Type": "Api",
            "Properties": {
              "RestApiId": {
                "Ref": "BasicAWSApiGateway"
              },
              "Path": "/token",
              "Method": "POST"
            }
          }
        }
      }
    }
  },
  "Outputs": {
    "BasicAWSApiGateway": {
      "Description": "API Gateway endpoint URL for Staging stage for Generate Token function",
      "Value": {
        "Fn::Sub": "https://${BasicAWSApiGateway}.execute-api.${AWS::Region}.amazonaws.com/Staging/token/"
      }
    },
    "BasicAWSApiGatewayRestApiId": {
      "Description": "API Gateway ARN for Basic AWS API Gateway",
      "Value": {
        "Ref": "BasicAWSApiGateway"
      },
      "Export": {
        "Name": "BasicAWSApiGateway-RestApiId"
      }
    },
    "BasicAWSApiGatewayRootResourceId": {
      "Value": {
        "Fn::GetAtt": [
          "BasicAWSApiGateway",
          "RootResourceId"
        ]
      },
      "Export": {
        "Name": "BasicAWSApiGateway-RootResourceId"
      }
    },
    "GenerateTokenFunction": {
      "Description": "First Lambda Function ARN",
      "Value": {
        "Fn::GetAtt": [
          "GenerateTokenFunction",
          "Arn"
        ]
      }
    },
    "GenerateTokenFunctionIamRole": {
      "Description": "Implicit IAM Role created for Generate Token function",
      "Value": {
        "Fn::GetAtt": [
          "GenerateTokenFunctionRole",
          "Arn"
        ]
      }
    }
  }
}
