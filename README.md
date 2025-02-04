
# **🚀 Deploying the AWS Environment with Terraform & GitHub Actions**

This guide outlines the **Terraform deployment process** for setting up your **network, RDS, Lambda, and S3** resources on AWS, along with **GitHub Actions flow** for automatic updates.

---

## **📌 Prerequisites**
Ensure you have the following installed:
- **AWS CLI** (`aws configure`)
- **Terraform** (`terraform -version`)
- **GitHub CLI** (optional)
- **IAM Permissions** to manage **S3, RDS, Lambda, API Gateway, and Secrets Manager**

---

## ** Step 1: Create the Terraform Backend S3 Bucket**
Terraform requires an **S3 bucket** to store its state.

```sh
aws s3 mb s3://tf-infra-aws --region us-east-1
```

Verify:
```sh
aws s3 ls | grep tf-infra-aws
```

---

## **📂 Step 2: Upload Lambda Deployment Packages to S3**
```sh
aws s3 cp app_lambda.zip s3://tf-infra-aws/app_lambda.zip
aws s3 cp db_migration.zip s3://tf-infra-aws/db_migration.zip
```

Verify:
```sh
aws s3 ls s3://tf-infra-aws/
```

---

## **🌐 Step 3: Deploy Network Module**
Navigate to the **network module** and apply Terraform.

```sh
cd tf-aws-infra/ue1/stag/network
terraform init
terraform plan
terraform apply -auto-approve
```

🚀 **Outputs**:
- **VPC ID**
- **Public & Private Subnet IDs**
- **Internet Gateway**
- **NAT Gateway**

---

## **💾 Step 4: Deploy RDS (PostgreSQL)**
Navigate to the **RDS module** and apply Terraform.

```sh
cd tf-aws-infra/ue1/stag/rds
terraform init
terraform plan
terraform apply -auto-approve
```

🚀 **Outputs**:
- **RDS Endpoint**
- **RDS Security Group ID**

---

## **🔧 Step 5: Update Lambda Configuration**
After deploying RDS, update the **Lambda environment variables**.

1. **Retrieve the RDS Endpoint**:
   ```sh
   terraform output -raw db_endpoint
   ```
2. **Update `tf-aws-infra/ue1/stag/lambda/main.tf`**:
   - Set `DB_HOST` to the **new RDS endpoint**.

---

## **🔐 Step 6: Create AWS Secrets Manager Entry for Database Password**
To securely store database credentials, use **AWS Secrets Manager**.

```sh
aws secretsmanager create-secret \
    --name db_password \
    --secret-string '{"db_password":"YourSecurePassword"}'
```

Verify:
```sh
aws secretsmanager list-secrets
```

---

## **📡 Step 7: Deploy Lambda & API Gateway**
Navigate to **Lambda module**.

```sh
cd tf-aws-infra/ue1/stag/lambda
terraform init
terraform plan
terraform apply -auto-approve
```

🚀 **Outputs**:
- **Lambda Function ARN**
- **API Gateway Endpoint**


---

## **🎭 Step 9: Configure Sentry for Monitoring**
Sentry helps with **error tracking**. Set up **Sentry DSN**:

```sh
export SENTRY_DSN="your-sentry-dsn"
```

Or create an **AWS Secret** for it:

```sh
aws secretsmanager create-secret \
    --name sentry_dsn \
    --secret-string '{"dsn":"your-sentry-dsn"}'
```

---

# **🛠 GitHub Actions Workflow Flow**
🚀 The **GitHub Actions CI/CD pipeline** automates deployments.

### **🔹 Flow Overview**
```
[ Push to GitHub ] → [ Detect Branch (stag/prod) ] → 
[ Deploy Frontend ] → [ Sync to S3 ] → 
[ Invalidate CloudFront Cache ] → 
[ Deploy Lambda ] → [ Upload ZIP to S3 ] → [ Update Lambda Code ]
```

---

# **✅ Summary**
🔹 **Terraform Steps**:
1. **Create S3 bucket & Upload Lambda files**
2. **Deploy Network** (`tf-aws-infra/ue1/stag/network`)
3. **Deploy RDS** (`tf-aws-infra/ue1/stag/rds`)
4. **Update `DB_HOST` in Lambda**
5. **Create AWS Secrets (`db_password`, `sentry_dsn`)**
6. **Deploy Lambda & API Gateway** (`tf-aws-infra/ue1/stag/lambda`)

🔹 **GitHub Actions Automates**:
1. **Frontend Deployment (S3 + CloudFront)**
2. **Lambda Deployment (Python Packages, ZIP, S3, Update Lambda)**

