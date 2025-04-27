# 02-Terraform-AWS---Remote-State-S3
![alt text](/Images/Pravash_Logo_Small.png)
## 🎯 Objective
In this Lab, I'll teach you:
> - Create an S3 Bucket using Terraform
> - Configure Terraform backend to store the state file remotely in that S3 bucket
> - Understand why remote backend is important

Before We start, Let's first understand what is a state file & why do we need to store the state file in a remote location?

The **core** to Terraform's functionality is the concept of **"state"** - a critical component that tracks the state of our infrastructure and configuration.

## 🔬 Understanding Terraform State
Terraform state is a JSON file that Terraform generates automatically during the terraform apply command. This file contains vital information about the resources Terraform creates, allowing Terraform to map real-world resources to your configuration and keep track of metadata.

## Why is State Important?
> - **Synchronization**: It ensures that Terraform's actions are based on the most current information about your infrastructure, preventing conflicts.
> - **Dependency Resolution**: Terraform uses the state to determine the order in which resources should be created, updated, or deleted.
> - **Inspection**: Users can query the state to inspect Terraform-managed infrastructure without accessing the cloud provider's console or API.

## Managing State Files
Terraform state can be managed locally or remotely, each with its own set of considerations for security and collaboration.

**Local State Management**:
By default, Terraform stores state locally in a file named terraform.tfstate. While this is simple and convenient for individual use, it poses challenges for team collaboration and security.
```
terraform {
  backend "local" {
    path = "relative/path/to/terraform.tfstate"
  }
}
```

**Remote State Management**:
For teams and projects requiring collaboration, remote state backends like AWS S3, Azure Blob Storage, or Google Cloud Storage are recommended. Remote backends offer several advantages:
* Shared Access: Team members can access the state concurrently, allowing for collaborative work on infrastructure.
* Security: Remote backends can be secured with encryption, access controls, and other cloud-provider security features.
* State Locking: Prevents concurrent state operations, reducing the risk of corruption.

**Example: Configuring an S3 Backend**
```
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "path/to/my/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
```
This configuration stores the state in an S3 bucket.

## Now, Let's proceed to the Lab.

## 🛠️ Pre-Requisites
* Terraform Installed
* AWS CLI Installed
* AWS IAM User with Programmatic Access (Access Key + Secret Key) & with proper S3 permissions.
* Basic knowledge from [01-Terraform-AWS---How-to-Start](https://github.com/PravashB/01-Terraform-AWS---How-to-Start.git)
* An Existing S3 Bucket (I'll explain why?)

# 📦 Lab Structure
```
02-Terraform-AWS---Remote-State-S3/
│
├── main.tf
├── provider.tf
├── backend.tf
├── variables.tf
└── outputs.tf
```

## Step 1: Create the Necessary Terraform Files

```
touch main.tf provider.tf backend.tf variables.tf outputs.tf
```
## Step 2: Add the contents in each file as below:

```
#main.tf
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }
}
```

```
#provider.tf
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

```
#backend.tf
terraform {
  backend "s3" {
    bucket = "terraform-remote-state-pro-lab" 
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```
> ⚡ Important: We've **Hardcoded** bucket name here, because Terraform needs it before the S3 bucket resource is created. We'll understand the purpose in sometime.
```
#outputs.tf
output "bucket_name" {
  description = "The name of the S3 bucket created"
  value       = aws_s3_bucket.terraform_state_bucket.bucket
}
```

## Step 3: Run `terraform init`
 ![alt text](/Images/image-2.png)

So, we got an error.
>  Error: Failed to get existing workspaces: S3 bucket "terraform-remote-state-pro-lab" does not exist.

This brings us to a very important concept. A li'l deviation. But trust me, it's worth it.

## 🛑 Very Important Concept - Bootstrap Project

> This is a famous terraform **"Chicken-and-egg"** problem.

**🧠 Why didn't we face this earlier?**

In the first lab, we were using local state (terraform.tfstate in your local folder).
Now, you’re moving to remote state, where Terraform must interact with an external system (S3), and it cannot dynamically create S3 buckets on its own during `terraform init.`.

**Why Should we fix this?**
- The backend (S3) is configured in backend block inside terraform {...}.
- Terraform must configure the backend first before any resources can even be created.
- Backend is **special** — Terraform treats it differently from normal resources.

Thus, the **S3 bucket must already exist** before Terraform can even start working properly.

**How to fix this?**
There are two standard ways:
1. Bootstrap Project. (For Teams & Production - Professional way)
2. Manual Creation. (For small projects and labs - For now)

>**⚡ In short:**
Backend must exist before `terraform init`. No way around it.
Bootstrap project creation is the professional solution. And we'll see that in another lab.

## Step 4: Manually Create an S3 bucket:
- ✅ Go to AWS Console ➔ S3 ➔ Create Bucket ➔ Name: terraform-remote-state-pro-lab.
- ✅ Done!
- ✅ Then terraform init will work fine.
 ![alt text](/Images/image-3.png)

## Step 5: Commands to Run
**1. Once again run `terraform init`** 
```
terraform init
```
![alt text](/Images/image-4.png)
**2. Plan**
 ```
 terraform plan -out=tfplan
 ```
 > Enter a value: terraform-remote-state-pro-lab --> The name of the bucket we created manually.
 ![alt text](/Images/image-6.png)
**3. Apply**
```
terraform apply tfplan
```
> Enter a value: terraform-remote-state-pro-lab --> The name of the bucket we created manually.

 ![alt text](/Images/image-7.png)
This applies the plan and moves the `terraform.tfstate` to the S3 bucket.
 ![alt text](/Images/image-8.png)

> - Now our terraform.tfstate is stored remotely in the S3 bucket under the key terraform.tfstate.
> - No local `terraform.tfstate` file will be visible anymore.

## Step 6: Clean Up

In order to destroy the bucket, we need to first delete the object (state file) inside the bucket manually and then we can delete the bucket.

---
> Prepared By: Pravash

> Last Updated: April 2025