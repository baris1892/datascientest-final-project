# DataScientest Final Project

This repository contains the final DevOps project developed as part of the DataScientest program.

The goal of this project is to design, deploy, and operate a microservices-based application using DevOps best
practices, including containerization, infrastructure as code, orchestration, and automation.

## Deployment Status

| Service      | Development                                                                                                                                                                                                     | Production                                                                                                                                                                                                   |
|:-------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Frontend** | [![Dev Status](https://img.shields.io/github/deployments/baris1892/datascientest-final-project/frontend-dev?label=status&style=flat-square)](https://dev.baris.cloud-ip.cc "Open Development Frontend")         | [![Prod Status](https://img.shields.io/github/deployments/baris1892/datascientest-final-project/frontend-prod?label=status&style=flat-square)](https://baris.cloud-ip.cc "Open Production Frontend")         |
| **Backend**  | [![Dev Status](https://img.shields.io/github/deployments/baris1892/datascientest-final-project/backend-dev?label=status&style=flat-square)](https://dev-api.baris.cloud-ip.cc/petclinic "Open Development API") | [![Prod Status](https://img.shields.io/github/deployments/baris1892/datascientest-final-project/backend-prod?label=status&style=flat-square)](https://api.baris.cloud-ip.cc/petclinic "Open Production API") |

## Project Overview

The application is based on the Petclinic microservices architecture and includes:

- **Frontend:** Angular
- **Backend:** Spring Boot (REST API)
- **Database:** PostgreSQL

The infrastructure is deployed on **Kubernetes (k3s)** and managed using **Helm**, **ArgoCD** and **Infrastructure as
Code** (Terraform) principles.

## Documentation

Detailed documentation is available in the [Documentation Guide](/docs/project-documentation.md):

- [1. Overview of the app](/docs/project-documentation.md#1-overview-of-the-app)
- [2. Architecture Diagram](/docs/project-documentation.md#2-architecture-diagram)
- [3. Tech Stack](/docs/project-documentation.md#3-tech-stack)
- [4. Setup Steps](/docs/project-documentation.md#4-setup-steps)
- [5. How to deploy dev & prod](/docs/project-documentation.md#5-how-to-deploy-dev--prod)
- [6. CI/CD](/docs/project-documentation.md#6-cicd)
- [7. Monitoring](/docs/project-documentation.md#7-monitoring)
- [8. Security](/docs/project-documentation.md#8-security)
- [9. Disaster Recovery](/docs/project-documentation.md#9-disaster-recovery)
