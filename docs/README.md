# Protagona Data Engineering Screening Exercise

## Overview

Our company, Trubblex, is in the process of developing and releasing an innovative new product. This product will help
us identify animals faster and do some additional downstream validation of the type of animal provided to our service.

Problem is, we are a startup. And we had exactly one engineer. Joe. Joe was our software developer, cloud engineer,
architect, and office WiFi specialist. He did it all. And he did it marvelously. That is, until last week when he quit
via WhatsApp after, allegedly, winning the lottery.

Trubblex is in a state of distress (we could call it _trouble_) and is looking to engage your services immediately to
fix and further the development of our _revolutionary_ microservice-based, Animal Identification product.

---

## Architecture

Our prototype has been in development in AWS on the `us-east-1` region. Below is one of the architectural diagrams that
Joe created for Trubblex --bask in all its glory!

![img](./architecture.png)

As you can appreciate from Joe's immense talent as an illustrator and visual communicator, the service is comprised of
Amazon s3, AWS Lambda, and Amazon Bedrock. We are certain there are other bits and bobs laying around, but we
could never get Joe to document them. So, that's that. Oh, and should probably mention that Joe _loved_ Terraform, as
well as CodeCommit/CodeBuild/CodePipeline.

---

## The Service

Our service protoype, which has been in development for 18+ months, requires that the user place an image of an animal
in an s3 bucket, that image is processed through a standard prompt for identification, and retrieve the results from a
separate bucket. This process is all written in Python and deployed through AWS Lambda

For some reason whenever we drop an image into the bucket, we only get a single static response, no matter how many
different images we process through. We would love to get this fixed so we can deploy this identification service to our
end users can stop emailing up pictures of their animals for identification, and waiting for a response from us.


## The Automation

Joe loved AWS. So, he built everything he could on top of native AWS Services. We are willing to bet that all of the
service required code lives in CodeCommit, and that the CI/CD pipeline was built on top of CodeBuild/Pipeline.

We can provide you with an AWS IAM user & password you can use to poke around. There's probably some limitations on how
much you'll be able to do directly on AWS IAM, given that we have some regulatory requirements that preclude us from
giving away IAM Users direct permissions to IAM.

---

## Your Mission

Should you chose to accept, here's what we need from you:

1. Inspect the state of the existing python code and troubleshoot why we are encountering so many issues
2. Based on the above, please prioritize:
   - **Functional requirements**: i.e. get our images processing correctly
   - **Performance Efficiency and Cost Optimization**: issue recommendations where we could make improvements to make
     better use of resources or services. We are a startup, but we don't have bottomless checkbooks!
   - **Service Improvements**: We understand the power of document identification in other industries (although animal
   - identification is rather lucrative). We would like to expand this service to offer other opportunities to apply
   - other prompts and/or update or change the prompts without having to reprocess a deployment (right now everything is
   - built int he code as we understand)
   - **Operational Excellence and Observability**: any improvements or additions that we could make to meet minimum
     observability requirements for a service of this nature, based on your experience, would be amazing. We've all been
     scrambling to figure out what SLO/SLA/KPI's to use. But we don't even know what those are. Much less where to
     begin. We suspect that if we had some visibility into the service operation (metrics, logging, etc...) we could
     eventually figure it out.
   - **Reliability**: we would appreciate your input to ensure the most stable experience to our end users. Any
     recommendations that would increase uptime, and availability of our services would be phenomenal.

---

## Access to our AWS Environment

You will (or have been) provided with an IAM User with two basic AWS Managed Policies:

- `arn:aws:iam::aws:policy/PowerUserAccess`
- `arn:aws:iam::aws:policy/AWSCodeCommitPowerUser`

Unfortunately these are the only two policies that we are able to extend to your user. Having said that, the automation
pipeline identity should be able to extend much farther that what those policies provide. The constraint, is that you'll
have to rely very heavily on codifying most of your work and leveraging pre-exisiting automation.
