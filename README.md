**GOAL**

Starting from a git repository we need to set up a development environment and create all
the required resources to deploy a new service.
We evaluate the process and your engagement in trying to solve this problem more than the
actual result. Feel free to describe what you are trying to do in every step.
You don't need to create any external resources or use any public cloud provider to test this
assignment.

**PROJECT**

**1 - Development environment**
Starting from a git repository (https://github.com/Rahul-Pandey7/react-image-compressor)
create a docker-compose file to build and bring up the service locally. Don't expose the
node.js container but instead create an nginx container that proxies and logs every request.

**2 - Kubernetes resources**
Now that you have a running environment with docker-compose try to convert it to
kubernetes files that have deployment and service definitions. Don't bother defining ingress
resources. How would you try it in your local environment?

**3 - Deployment to production**
Now that you have a kubernetes configuration it's time to deploy it in production.
We want to automate every step, so it would be really nice to have a terraform configuration
that creates a bunch of AWS resources:
- an ECR repository
- a Codebuild project
Try also to create a buildspec.yml file that contains every step to build and deploy this
project.
You can run Codebuild locally on your machine to test it. To do that, follow these instructions:
- https://docs.aws.amazon.com/codebuild/latest/userguide/use-codebuild-agent.html
- https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/

AWS works with IAM roles that every resource can assume in order to be able to execute its
tasks.
The Codebuild project requires a service role to do its job, but you don't need to define it
properly. Can you think of the policies it must have to complete its build and deployment
task?
