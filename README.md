# **Shortlet (Time API) on GCP with Terraform and Kubernetes**

## **Project Overview**

This project demonstrates the deployment of a simple Time API on Google Cloud Platform (GCP) using Google Kubernetes Engine (GKE) and Terraform for Infrastructure as Code (IaC). The API returns the current time in JSON format and is containerized using Docker. The deployment process is fully automated with a CI/CD pipeline implemented via GitHub Actions.

![project image](images/project-image.png)

## **Table of Contents**

1. [Architecture](#architecture)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Setup and Deployment](#setup-and-deployment)
   - [Local Setup](#local-setup)
   - [Google Cloud Platform Setup](#google-cloud-platform-setup)
   - [GitHub Setup](#github-setup)
5. [API Development and Containerization](#api-development-and-containerization)
6. [Infrastructure Setup](#infrastructure-setup)
7. [CI/CD Pipeline](#ci-cd-pipeline)
8. [Network Security](#network-security)
9. [Monitoring and Logging](#monitoring-and-logging)
10. [Testing the Setup](#testing-the-setup)
11. [Possible Improvements](#possible-improvements)

## **Architecture**

This project sets up the following infrastructure on GCP:
- A **Google Kubernetes Engine (GKE) cluster** to host the Time API.
- A **NAT gateway** for managing outbound traffic from the GKE cluster.
- **IAM roles and policies** for secure access management.
- **VPC networking**, including subnets and firewall rules.
- Kubernetes resources such as **Namespaces, Deployments and Services**.

## **Prerequisites**

Before proceeding with the deployment, ensure you have the following:
- A GCP account with billing enabled.
- A GCP project set up.
- Terraform installed on your local machine.
- Docker installed on your local machine.
- GitHub repository with the necessary secrets for CI/CD 
- Google Cloud SDK installed locally
- Node.js and npm installed locally (for local testing)



## Project Structure

```
.
├── .github
│   └── workflows
│       └── ci-cd.yaml
├── app
│   ├── app.js
│   ├── Dockerfile
│   └── package.json
├── terraform
│   └── bucket
│       └── main.tf
│       └── variables.tf
│       └── outputs.tf
│   ├── backend.tf
│   ├── gke.tf
│   ├── iam.tf
│   ├── kubernetes.tf
│   ├── monitoring.tf
│   ├── nat.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── vpc.tf
└── README.md
```

## Setup and Deployment

### Local Setup

1. Clone the repository:
   ```
   git clone https://github.com/Dev26x/shortlet.git
   cd shortlet
   ```

2. Install dependencies:
   ```
   cd app
   npm install
   ```

3. Run the application locally:
   ```
   node app.js
   ```

4. Test the API:
   ```
   curl http://localhost:3000
   ```

### Google Cloud Platform Setup

1. Create a new GCP project or use an existing one.

2. Ensure that the following APIs are enabled in your GCP project:
   - Kubernetes Engine API
   - Cloud Resource Manager API
   - IAM Service Account Credentials API
   - Compute Engine API
   - Container Registry API
   - Cloud Monitoring API
   - Cloud Logging API
   - Cloud Trace API
   - Cloud Profiler API

3. Create a service account for Terraform with the "Editor" role and download the JSON key file.

4. Use *gcloud auth login* to authenticate and connect to your google cloud provider.

### GitHub Setup

1. In the github repository, go to Settings > Secrets and add the following secrets:
   - `GCP_PROJECT_ID`: GCP project ID
   - `GCP_SERVICE_ACCOUNT_KEY`: The content of the service account JSON key file (*Remember to encode in BASE64 to ensure that your JSON key is handled safely and effectively within GitHub Secrets and your automated workflows.*)
   - `TF_VAR_project_id`: GCP project ID
   - `TF_VAR_region`: Preferred GCP region 
   - `TF_VAR_location`: Preferred GCP zone 
   - `TF_VAR_cluster_name`: Preferred GKE cluster name



## **API Development and Containerization**

### **API Development**

The API is a simple Node.js application that returns the current time in JSON format when accessed via a GET request. The code is in `app/app.js`:

```
Javascript

const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.json({ currentTime: new Date().toISOString() });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

### **Containerization**

To containerize the application, a Dockerfile is created as shown below:

```
Dockerfile

FROM node:14-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

### **Build and Push Docker Image to Google Container Registry (GCR)**

To build and push the Docker image to GCR, follow these steps:

1. **Build Docker image**
 ```
   docker build -t shortlet-app-image:latest .
 ```

 ![containerize app](images/containerize-1.png)


 view the images with 
 ```
    docker images
 ```

 ![docker image](images/dockerimage.png)

2. **Authenticate with GCP:**
   ```
   gcloud auth login
   gcloud auth configure-docker
   ```

3. **Push the Docker image to GCR:**
   ```
   docker build -t gcr.io/${PROJECT_ID}/${PROJECT_ID}/-image:latest
   ```

   ![gcr image push](images/gcr-push.png)


## **Infrastructure Setup**

### **Terraform Configuration**

The project uses Terraform to manage the entire infrastructure on GCP. 

The terrain configuration files are applied by running:

```
terraform init

terraform apply
```

*Run the commands first in the terraform/bucket subdirectory before running the commands in the terraform root. This is because our backend.tf in terraform root is dependent on the state bucket.*


The main components include:

- **GKE Cluster and Node Pool (`terraform/gke.tf`):** 
  Sets up a GKE cluster with a primary node pool.

  Result:

  ![gke deployed](images/gke-deployed.png)

  ![gke cluster](images/gke-cluster.png)

- **VPC and Networking (`terraform/vpc.tf`):**
  Configures a custom VPC, subnets, and firewall rules.

  Result:

  ![shortlet network](images/shortlet-network.png)


  ![firewalls](images/firewalls.png)


- **IAM Roles and Policies (`terraform/iam.tf`):**
  This terraform configuration file creates a service account for CI/CD with appropriate roles.

  Result: 

  ![service account](images/service-acct.png)

- **NAT Gateway (`terraform/nat.tf`):**
  Manages outbound traffic from the GKE cluster.

- **Kubernetes Resources (`terraform/kubernetes.tf`):**
  Defines the Kubernetes Namespace, Deployment, and Service for the API.

  After deployment, set the kubrnetes context to your current context using these  commands:

  ```
  kubectl config get-contexts

  kubectl config use-context [context name] 
  ```

  Result:

  ![Set Context](images/set-context.png)

  ![cluster details](images/cluster-details-1.png)

  ![cluster details](images/cluster-details-2.png)

- **Google Cloud Storage bucket (`terraform/bucket/main.tf`):**
  Creates the bucket that saves Terraform state, helping to avoid conflict.
 
  Result:
  ![state bucket](images/state-bucket.png)

## **CI/CD Pipeline**

### **GitHub Actions Workflow**

The project uses GitHub Actions for continuous integration and deployment. The pipeline performs the following steps:

1. Checkout the code
2. Set up Google Cloud SDK
3. Authenticate to Google Cloud
4. Enable required APIs
5. Build and push the Docker image to GCR
6. Initialize and apply Terraform for the state bucket
7. Initialize and apply Terraform for the main infrastructure
8. Verify the deployment by checking the application URL



![ci-cd success](images/ci-cd-success.png)


## **Network Security**

The following security measures were taken:
1. Private GKE cluster with authorized networks
2. Workload Identity for secure pod-to-GCP-services communication
3. Cloud NAT for controlled egress traffic
4. Firewall rules to restrict access to the cluster
5. Minimal IAM permissions for service accounts

Policy as code (PAC) was done implicitly via the terraform files for NAT, VPC and IAM.

## Monitoring and Logging

The project enables the following GCP services for monitoring and logging:

- Cloud Monitoring
- Cloud Logging
- Cloud Trace
- Cloud Profiler

![monitoring](images/monitoring.png)

![logging](images/logging.png)

## Testing the Setup

The app can be tested locally by running the following command

```
node app.js
```

![local test](images/localhost.png)


After deployment on GCP, the app can be viewed via the app url.

![result](images/result.png)


## Possible Improvements
- Implement Horizontal Pod Autoscaling (HPA) in Kubernetes to automatically scale the API based on load.
- Refactor the Terraform code into reusable modules to organize and reuse common infrastructure components.
- Implement secret management using Google Secret Manager or Kubernetes Secrets.
- Use Terraform's Sentinel for explicit policy enforcement.

