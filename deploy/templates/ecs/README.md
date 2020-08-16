# Task's Role

There are two types of roles that will be assigned to ECS task.  

Since the actor/identity gonna be a Machine - you also have to enable assumeRole policy on the following roles. So that our ecs task can assume the role we defined here.

## Role 1: Task Exec Role

It's a role that is used for starting a service.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
```

- it allows our ECS task to retrieve the image from ECR
- it put logs in to the log stream.
- allows to create new log stream.


## Role 2: Task Role

Permission given to the actual running tasks itself (at runtime, after service is started)


- access to S3 bucket. 