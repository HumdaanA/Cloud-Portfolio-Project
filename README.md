# Cloud Portfolio Project

This project is my implementation of the **Cloud Resume Challenge**, where I built and deployed a fully serverless, cloud-based resume using AWS services and Infrastructure as Code (IaC). The project includes a static website, a visitor counter, and a CI/CD pipeline using GitHub Actions.

## 🚀 Project Overview

### Tech Stack
- **Frontend**: HTML, CSS, JavaScript (Static Website hosted on S3 + CloudFront)
- **Backend**: AWS Lambda (Python), API Gateway, DynamoDB
- **Infrastructure as Code (IaC)**: Terraform
- **CI/CD**: GitHub Actions
- **Domain & SSL**: AWS Route 53 + AWS Certificate Manager

### 🌍 Live Webiste

[View my Cloud Portfolio here](https://www.humdaan-ahmad-portfolio.com/)

## 🏗️ Architecture

[View Workflow Here](https://drive.google.com/file/d/1FryIbIruqJkdhFmA0aQYzJ8Q4bHJ1HkZ/view?usp=sharing)

The project consists of the following AWS services and technologies:

1. **Frontend (Static Website)**
   - HTML, CSS, and JavaScript hosted in an S3 bucket with static website hosting enabled.
   - Served securely via CloudFront with an SSL certificate from AWS Certificate Manager.
   - Custom domain registered and managed with Route 53.

2. **Visitor Counter (Backend API)**
   - AWS API Gateway to expose a public endpoint for the visitor counter.
   - AWS Lambda (Python) to process requests and update the visitor count.
   - DynamoDB to store the visitor count with high availability.

3. **CI/CD Pipeline (GitHub Actions)**
   - Automatically deploys frontend updates to S3 and invalidates the CloudFront cache.
   - Deploys infrastructure updates using Terraform whenever changes are pushed.


## Features

✅ Static Website Hosting with S3
✅ SSL-secured with CloudFront & ACM
✅ DynamoDB for visitor count storage
✅ AWS Lambda & API Gateway for Backend
✅ CI/CD Pipeline with GitHub Actions
✅ Infrastructure as Code using Terraform
