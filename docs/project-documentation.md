# Datascientest Final Project Documentation

## Contents

1. [Overview of the app](#1-overview-of-the-app)
2. [Architecture Diagram](#2-architecture-diagram)
3. [Tech Stack](#3-tech-stack)
4. [Setup Steps](#4-setup-steps)
5. [How to deploy dev & prod](#5-how-to-deploy-dev--prod)
6. [CI/CD](#6-cicd)
7. [Monitoring](#7-monitoring)
8. [Security](#8-security)
9. [Disaster Recovery](#9-disaster-recovery)

---

## 1. Overview of the app

The **Spring Petclinic** is a classic sample application designed to demonstrate the Spring Framework. In this project,
the application serves as the foundation for a modern, decoupled microservices architecture.

### Business & Technical Goals

- **Operational Efficiency:** Providing a stable environment to manage veterinary data (owners, pets, and visits).
- **Modernization:** Transitioning from a monolithic-style service to a decoupled frontend-backend architecture.
- **Scalability & Reliability:** Enabling independent scaling of components and replacing volatile in-memory storage
  with a persistent **PostgreSQL** database to ensure data integrity.
- **Automation:** Implementing a full **CI/CD pipeline** to eliminate manual deployment errors and ensure rapid,
  reliable delivery.

### Core Components

- **Backend:** A Java Spring Boot REST API providing the business
  logic ([petclinic-rest](https://github.com/spring-petclinic/spring-petclinic-rest))
- **Frontend:** An Angular-based web interface for user
  interaction ([petclinic-angular](https://github.com/spring-petclinic/spring-petclinic-angular))
- **Database:** A PostgreSQL instance for persistent data storage (replacing the default HSQL in-memory DB)

### Project Methodology (Brief)

The project was managed using an **Agile/Kanban** approach. Tasks were tracked via **GitHub Issues** and a **Project
Board** to ensure transparency and structured progress through the various DevOps implementation phases.

<details>
  <summary>Kanban Board Screenshot</summary>
  <figure>
    <img src="./assets/github-kanban-board.png" alt="GitHub Kanban Board">
    <figcaption><i>Screenshot of GitHub Project Management setup</i></figcaption>
  </figure>
</details>

---

## 2. Architecture Diagram

Include:

- Application components
- CI/CD pipeline
- Infrastructure
- K8s architecture

---

## 3. Tech Stack

---

## 4. Setup Steps

---

## 5. How to deploy dev & prod

---

## 6. CI/CD

---

## 7. Monitoring

---

## 8. Security

---

## 9. Disaster Recovery

### 9.1 Backup Strategy for Databases:

- **Backup Automation**: A Kubernetes CronJob triggers a `pg_dump` daily at 02:00 AM.
- **Storage & Retention**: Dumps are stored on the host VM via `hostPath` at `/home/backups/database`. A retention
  policy of 7 days is enforced within the backup script.
- **Recovery Plan**: To ensure a consistent state during recovery and avoid 'already exists' errors, the public schema
  is dropped and recreated before the restore. This guarantees that any data added after the backup or manual schema
  changes are completely removed, resulting in a 1:1 copy of the backed-up state.
  ```
  # Extract credentials from secret
  export PGUSER=$(kubectl get secret database-db-secret -n dev -o jsonpath="{.data.POSTGRES_USER}" | base64 --decode)
  export PGDATABASE=$(kubectl get secret database-db-secret -n dev -o jsonpath="{.data.POSTGRES_DB}" | base64 --decode)
  export PGPASSWORD=$(kubectl get secret database-db-secret -n dev -o jsonpath="{.data.POSTGRES_PASSWORD}" | base64 --decode)
  
  # 1. Delete schema and recreate it
  # We pass PGPASSWORD into the pod environment so psql can use it
  kubectl exec -i database-db-0 -n dev -- env PGPASSWORD=$PGPASSWORD psql -U $PGUSER -d $PGDATABASE -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
  
  # 2. Restore DB based on DB Dump
  gzip -d -c /home/baris/backups/database/db_dump_2026-01-10_11-52-40.sql.gz | kubectl exec -i database-db-0 -n dev -- env PGPASSWORD=$PGPASSWORD psql -U $PGUSER -d $PGDATABASE
  ```
- Production note: In a production environment, backups would be stored on external object storage (e.g. AWS S3).

### 9.2 Recover in case of Container or Node Failure

- **Container Failure**: Kubernetes monitors container health via Liveness/Readiness probes. If a container crashes, K8s
  automatically restarts it (self-healing).
- **Node Failure Strategy**:
    - **Current State**: The project currently operates on a single-node k3s cluster. A node failure would result in
      downtime.
    - **Recovery Procedure**: In case of a node failure, the VM must be restarted. Since all components are defined via
      IaC (Terraform) and Helm, the cluster can be redeployed from scratch within minutes if the hardware is lost.
    - **Scalability Note**: In a multi-node production environment, Kubernetes would automatically reschedule pods to
      healthy nodes (self-healing).

### 9.3 Infrastructure Redeployment (IaC)

The redeployment is split into two logical layers to manage dependencies effectively:

1. **Base Layer (Manual)**: Provisioning of the VM and installation of k3s (without Traefik), SOPS/Age for secrets and
   Terraform.
2. **Cluster Infrastructure (IaC - `infra/`)**:
   Running `terraform apply` in the `infra` folder deploys shared cluster services:
    - **Traefik** (Ingress Controller)
    - **Cert-Manager** (SSL Management)
    - **ArgoCD** (GitOps Controller)

3. **Application Environments (IaC - `environments/`)**:
   Running `terraform apply` in `environments/dev` or `environments/prod` configures the specific environment settings
   and triggers the ArgoCD "App-of-Apps" pattern.
4. **GitOps Synchronization**: ArgoCD monitors the Git repository and ensures that the Helm charts (from the `charts/`
   folder) are deployed and kept in sync with the cluster state.

**Disaster Recovery Scenario**: To restore the system from scratch, an engineer simply needs to restore the `age.key`,
run Terraform in `infra` and then in the respective `environment` folder. ArgoCD will handle the rest.

### 9.4 How to roll back to a previous version

Since the project follows the GitOps principle using ArgoCD, the source of truth is the Git repository.

**Rollback Procedure**:

1) **Git Revert**: Revert the last commit in the Git repository to a known stable state and push the changes.
2) **ArgoCD Sync**: ArgoCD detects the change in Git and automatically synchronizes the cluster to the previous version.
