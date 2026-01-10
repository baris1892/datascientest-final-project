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

Please refer to the [docs](/docs) folder for architecture, setup, and implementation details.