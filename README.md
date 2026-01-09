# DataScientest Final Project

This repository contains the final DevOps project developed as part of the DataScientest program.

The goal of this project is to design, deploy, and operate a microservices-based application using DevOps best
practices, including containerization, infrastructure as code, orchestration, and automation.

## Deployment Status

| Service      | Environment | Status                                                                                                                            | URL                                                    |
|:-------------|:------------|:----------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------|
| **Frontend** | Production  | ![Prod Status](https://img.shields.io/github/deployments/baris1892/datascientest-final-project/frontend-prod?label=frontend-prod) | [Frontend PROD](https://baris.cloud-ip.cc)             |
|              | Development | ![Dev Status](https://img.shields.io/github/deployments/baris1892/datascientest-final-project/frontend-dev?label=frontend-dev)    | [Frontend DEV](https://dev.baris.cloud-ip.cc)          |
| **Backend**  | Production  | ![Prod Status](https://img.shields.io/github/deployments/baris1892/datascientest-final-project/backend-prod?label=backend-prod)   | [API PROD](https://api.baris.cloud-ip.cc/petclinic)    |
|              | Development | ![Dev Status](https://img.shields.io/github/deployments/baris1892/datascientest-final-project/backend-dev?label=backend-dev)      | [API DEV](https://dev-api.baris.cloud-ip.cc/petclinic) |

## Project Overview

The application is based on the Petclinic microservices architecture and includes:

- **Frontend:** Angular
- **Backend:** Spring Boot (REST API)
- **Database:** PostgreSQL

The infrastructure is deployed on **Kubernetes (k3s)** and managed using **Helm**, **ArgoCD** and **Infrastructure as
Code** (Terraform) principles.

## Documentation

Please refer to the [docs](/docs) folder for architecture, setup, and implementation details.