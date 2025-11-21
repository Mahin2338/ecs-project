# Umami Analytics Deployment on AWS ECS

A containerised deployment of Umami (open-source web analytics) on AWS using ECS Fargate, with full CI/CD pipeline and infrastructure as code.

## What This Is

This project deploys Umami analytics to AWS using modern DevOps practices. The entire infrastructure is defined in Terraform, the application runs in Docker containers on ECS Fargate, and GitHub Actions handles automatic deployments when code is pushed.

I built this to learn production-grade cloud infrastructure - it's a complete implementation with VPC networking, load balancing, database, SSL certificates, and automated deployments.

## Architecture

The setup uses AWS ECS Fargate to run containers without managing servers. The architecture includes:

- **VPC**: Custom VPC with public and private subnets across 2 availability zones for high availability
- **ECS Fargate**: Runs the containerised Umami application
- **RDS PostgreSQL**: Managed database for storing analytics data
- **Application Load Balancer**: Handles incoming traffic and SSL termination
- **Route53**: DNS management for custom domain
- **ECR**: Stores Docker images
- **ACM**: SSL/TLS certificates for HTTPS

Traffic flows: User → Route53 → ALB (HTTPS) → ECS Container → RDS Database

The containers live in private subnets and can't be accessed directly from the internet. They reach out through a NAT Gateway when needed (like pulling images or making API calls), and the load balancer in the public subnet handles all incoming traffic.

## Tech Stack

- **Infrastructure**: Terraform (modular setup with separate modules for VPC, ECS, RDS, ALB)
- **Container**: Docker (multi-stage build for smaller images)
- **Application**: Umami (Next.js based analytics platform)
- **Database**: PostgreSQL 16 on RDS
- **CI/CD**: GitHub Actions
- **Cloud**: AWS (eu-west-2 region)

## Project Structure
```
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── vpc/
│       ├── ecs/
│       ├── rds/
│       ├── alb/
│       └── security/
├── umami/
│   └── Dockerfile
├── .github/
│   └── workflows/
│       └── deploy.yml
└── README.md
```
## The diagram 
<img width="1151" height="1151" alt="ECS drawio" src="https://github.com/user-attachments/assets/54d07dea-c335-4290-9cf1-798e022dd464" />




## How It Works

### The Dockerfile

Uses a multi-stage build to keep the final image small. Stage 1 builds the application with all dependencies and build tools, then Stage 2 creates a clean production image with only what's needed to run.

The build process is specific to Umami - it uses separate build commands for different parts of the app (tracker, geolocation, main app) instead of a single build command. This avoids issues with database connections during the build.

Key points:

- Runs as non-root user for security
- Uses pnpm (Umami's package manager)
- Final image is around 150MB vs 800MB if built in a single stage
- Includes Prisma for database migrations

### The Infrastructure

Everything is defined in Terraform and organised into modules. The VPC module creates the network foundation with public and private subnets. ECS runs the containers, RDS handles the database, and the ALB manages traffic.

Security groups are configured so each service can only talk to what it needs:

- ALB accepts traffic from the internet on ports 80 and 443
- ECS only accepts traffic from the ALB
- RDS only accepts connections from ECS

I chose Fargate over EC2 because it's simpler - no servers to patch or maintain. It's more expensive than running your own EC2 instances, but for a learning project the trade-off is worth it.

### The CI/CD Pipeline

When code is pushed to the main branch, GitHub Actions:

1. Checks out the code
2. Logs into AWS and ECR
3. Builds the Docker image
4. Tags it with 'latest'
5. Pushes to ECR
6. Updates the ECS service to use the new image
7. Waits for the deployment to complete

The whole process takes about 5-10 minutes. ECS does a rolling deployment so there's no downtime - it starts the new container, waits for health checks to pass, then stops the old one.

## Local Development

To run this locally:
```bash
# Clone the repo
git clone <your-repo>
cd umami-project/umami

# Build the image
docker build -t umami:local .

# Run it (replace with your DB credentials)
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://user:pass@host:5432/umami" \
  umami:local

# Visit http://localhost:3000
```

## Deployment

The infrastructure deploys in this order:
```bash
cd terraform

# Initialise Terraform
terraform init

# Plan the changes
terraform plan

# Apply (will ask for confirmation)
terraform apply
```

You'll need to provide some variables (database password, domain name, etc). I keep these in a `terraform.tfvars` file that's not checked into git.

After the infrastructure is up, the CI/CD pipeline handles deployments automatically.

## Challenges I Hit

**Database migrations during build**: Initially tried using the standard `pnpm run build` command but it tried to connect to a real database during the Docker build, which doesn't exist at that point. Fixed by using Umami's specific build commands that generate Prisma client without connecting.

**Certificate validation**: The ACM certificate stays in pending status until you add the validation DNS records. Terraform can handle this automatically with the right resources, but getting that setup right took some trial and error.

**NAT Gateway costs**: These cost about £30/month each just to exist, plus data transfer fees. I'm using one NAT Gateway instead of two (one per AZ) to save costs. In production you'd want two for true high availability.

## What I'd Do Differently

If I were deploying this for real production use:

- Add CloudWatch alarms for high CPU, memory, error rates
- Use AWS Secrets Manager for the database password instead of Terraform variables
- Set up proper log aggregation and monitoring
- Add auto-scaling rules for the ECS service
- Use tagged images (commit SHA) instead of 'latest' for easier rollbacks
- Add a second NAT Gateway for better availability
- Set up proper backup and disaster recovery procedures

## Screenshots
<img width="1920" height="1080" alt="Screenshot (435)" src="https://github.com/user-attachments/assets/7b66538f-1440-40e7-a123-9160b04f3f26" />

<img width="1920" height="1080" alt="Screenshot (433)" src="https://github.com/user-attachments/assets/efa27804-3467-4963-95f8-e4a1fd3f0a14" />

<img width="1920" height="1080" alt="Screenshot (436)" src="https://github.com/user-attachments/assets/0570fb6c-eddd-4978-bbab-dc45c6409711" />



## Costs

Running this 24/7 costs roughly:

- ECS Fargate: ~£15/month (512 CPU, 1GB RAM)
- RDS db.t3.micro: ~£15/month
- NAT Gateway: ~£30/month
- ALB: ~£16/month
- Route53: ~£0.50/month

Total: Around £80/month

You can reduce this by stopping non-essential resources when not in use, or using smaller RDS instances.

## What I Learned

This project taught me how all the AWS networking pieces fit together. Understanding security groups, how traffic flows through subnets, when you need a NAT Gateway vs an Internet Gateway - that stuff only really clicks when you build it yourself.

The multi-stage Docker build was interesting too. It's not obvious at first why you'd want two stages, but when you see the size difference (2gbMB vs 150MB) it makes sense.

Getting CI/CD right took a few tries. The authentication between GitHub and AWS, making sure the pipeline has the right permissions, handling the image tagging - lots of small details that matter.

## Resources

- [Umami Documentation](https://umami.is/docs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/intro.html)
```

