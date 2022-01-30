Assignment 3:
-------------------
#### Problem Statement
1. Write a python program on AWS Lambda to stop EC2 instances at 10:00 PM UTC and start at 9:00 AM UTC

#### Solution
#### Step 1: Create an IAM policy and execution role for your Lambda function
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Start*",
        "ec2:Stop*"
      ],
      "Resource": "*"
    }
  ]
}
```
### Step 2: Create Lambda function to stop EC2 instances
1. In the AWS Lambda console, choose Create function
2. Choose Author from Scratch
3. Under Basic information, add the following:
 - For Function name, enter a name that identifies it as the function used to stop your EC2 instances - "StopEC2Instances"
 - For Runtime, choose Python 3.9
 - Under Permissions, expand Change default execution role
 - Under Execution role, choose Use an existing role
 - Under Existing role, choose the IAM role that we created in Step #1
4. Choose Create function
5. Under Code, Code source, copy and paste the following code into the editor pane in the code editor ( lambda_function). This code stops the EC2 instances that you identify
```
import boto3
region = 'ap-south-1'
instances = ['i-03797fa7853452656', 'i-084ff14c0bb016e0c']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))
```
6. Choose Deploy
7. On the Configuration tab, choose General configuration, Edit. Set Timeout to 10 seconds and then select Save

#### Step 3: Schedule the Lambda function using CloudWatch Event
1. Open the Amazon CloudWatch console
2. Choose Events, and then choose Create rule
3. Choose Schedule under Event Source
4. Enter cron expression that tells Lambda to stop your instances at 10 PM UTC
```
0 22 * * ? *
```
5. Choose Add target, and then choose Lambda function
6. For Function, choose the Lambda function that stops your instances
7. Choose Configure details and enter the following
 - Name: StopEC2Instances
 - Description: Stops EC2 instances every day at 10 PM UTC
 - State: Enabled
8. Choose Create rule

#### Step 4: Create Lambda function to start EC2 instances
1. In the AWS Lambda console, choose Create function
2. Choose Author from Scratch
3. Under Basic information, add the following:
 - For Function name, enter a name that identifies it as the function used to stop your EC2 instances - "StartEC2Instances"
 - For Runtime, choose Python 3.9
 - Under Permissions, expand Change default execution role
 - Under Execution role, choose Use an existing role
 - Under Existing role, choose the IAM role that we created in Step #1
4. Choose Create function
5. Under Code, Code source, copy and paste the following code into the editor pane in the code editor ( lambda_function). This code start the EC2 instances that you identify
```
import boto3
region = 'ap-south-1'
instances = ['i-03797fa7853452656', 'i-084ff14c0bb016e0c']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))
```
6. Choose Deploy
7. On the Configuration tab, choose General configuration, Edit. Set Timeout to 10 seconds and then select Save

#### Step 5: Schedule the Lambda function using CloudWatch Event
1. Open the Amazon CloudWatch console
2. Choose Events, and then choose Create rule
3. Choose Schedule under Event Source
4. Enter cron expression that tells Lambda to start your instances at 9 AM UTC
```
0 09 * * ? *
```
5. Choose Add target, and then choose Lambda function
6. For Function, choose the Lambda function that start your instances
7. Choose Configure details and enter the following
 - Name: StartEC2Instances
 - Description: Start EC2 instances every day at 10 PM UTC
 - State: Enabled
8. Choose Create rule