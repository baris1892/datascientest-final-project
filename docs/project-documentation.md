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

![Architecture Diagram](./assets/architecture.svg)

This diagram illustrates the end-to-end cloud-native lifecycle of the application. It is divided into three main logical
layers:

- **CI/CD & GitOps Layer**: Handles the automated DevSecOps pipeline from code push to deployment using GitHub Actions
  and
  ArgoCD.
- **Infrastructure Layer**: The foundation based on k3s and Proxmox, including networking (Traefik) and automated SSL
  management.
- **K8s Architecture (Workloads)**: The logical organization of application components using Deployments, StatefulSets
  and
  Namespaces for environment isolation.
- **Observability**: Centralized monitoring of cluster health and application metrics.

---

## 3. Tech Stack

| Category             | Technology       | Usage & Purpose                                                   |
|----------------------|------------------|-------------------------------------------------------------------|
| **Frontend**	        | Angular          | Single Page Application (SPA) for the user interface.             |
| **Backend**          | Spring Boot      | RESTful API handling business logic and database interactions.    |
| **Database**         | PostgreSQL       | Relational database for persistent storage of application data.   |
| **Containerization** | Docker           | Creating docker images using multi-stage builds.                  |
| **Orchestration**    | k3s (Kubernetes) | Lightweight Kubernetes distribution running on Proxmox VM.        |
| **Infrastructure**   | Terraform        | Infrastructure as Code (IaC) for provisioning K8s resources.      |
| **CI/CD Pipeline**   | GitHub Actions   | Automated build, test and containerization workflow.              |
| **GitOps**           | ArgoCD           | Declarative continuous delivery and cluster synchronization.      |
| **Security**         | Trivy            | Vulnerability scanning for Docker images within the pipeline.     |
| **Secret Mgmt.**     | SOPS & age       | Encryption of sensitive data (Secrets) within the Git repository. |
| **Certificates**     | cert-manager     | Automated HTTPS/TLS via Let's Encrypt.                            |
| **Observability**    | Prometheus       | Metric collection and monitoring of cluster and app health.       |
| **Visualization**    | Grafana          | Centralized dashboards for infrastructure and app metrics.        |

---

## 4. Setup Steps

---

## 5. How to deploy dev & prod

**Frontend environment configuration**

- To inject environment-specific variables into the Angular frontend, a dynamic `assets/env.js` file is used
- This file is referenced in `petclinic-angular/src/environments/environment.prod.ts`
- In Kubernetes, the `assets/env.js` is overridden via a ConfigMap per environment
- Example: `REST_API_URL` is dynamically injected for dev / prod environments
- This approach avoids hardcoding environment variables in the application and enables reusable deployments

---

**Persistence & restart validation**
Validation steps

- Delete PostgreSQL pod manually
- Restart k3s / cluster node
- Verify that:
    - Same PVC is reattached
    - Database data is preserved

Outcome

- PVC remains bound
- PostgreSQL restarts with existing data intact

---

- Multi-Environment Strategy: We use a "Build Once, Deploy Anywhere" approach. The same Helm charts and Terraform
  modules are used for dev and prod.
- Environment Injection: Environment-specific configurations are managed via values-dev.yaml and values-prod.yaml,
  ensuring minimal duplication.

## 6. CI/CD

- Declarative Setup: All infrastructure and application states are defined declaratively in YAML/HCL. This allows for
  fully automated, repeatable deployments and ensures that both environments stay in sync.


- From slack requirements:
    - Use different environment variables for each environment.
    - Use separate configuration files or values for dev vs prod.
    - Deploy dev automatically and production after approval (if using CI/CD).
    - Document the differences in configuration.

---

## 7. Monitoring

To ensure high availability and observability, the project implements a comprehensive monitoring stack based on
**Prometheus** and **Grafana** ([Dashboard](https://monitoring.baris.cloud-ip.cc/)), deployed via the **Prometheus
Operator** Helm Chart (`kube-prometheus-stack`).

### Key Components

- **Infrastructure Monitoring**: Automated collection of CPU, Memory, and Network metrics via `node-exporter`.
- **Database Monitoring**: Integration of `prometheus-postgres-exporter` to track PostgreSQL health and performance.
- **Monitoring Availability FE/BE**: Deployment of the Prometheus Blackbox Exporter to perform external HTTP/HTTPS
  health checks on Frontend and Backend endpoints.
- **Alerting Pipeline**: Custom `PrometheusRules` to trigger alerts for critical failures (e.g., database downtime).

Tip: The Grafana `admin` password can be retrieved via:  
```kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo```

### Demonstration: Fault Tolerance & Alerting

To verify the alerting pipeline, a database failure was simulated in the dev namespace by scaling the PostgreSQL
StatefulSet to zero replicas.

**Scenario Workflow:**

1. Failure Injection: `kubectl -n dev scale statefulset database-db --replicas=0`
2. Detection: The Postgres Exporter reports `pg_up 0`, while
   the [exporter's scrape target](https://prometheus.baris.cloud-ip.cc/targets?search=postgres) remains "UP" (indicating
   the monitoring side is still functional).
3. Alert Trigger: After a 1-minute grace period (`for: 1m`), Prometheus transitions the `PostgresDown` alert to the
   FIRING state.
4. Visualization: The alert is dynamically labeled with the affected namespace (`dev`) and displayed in the [Grafana
   Alerting UI](https://monitoring.baris.cloud-ip.cc/alerting/Prometheus/pri%24Prometheus%24%1Fetc%1Fprometheus%1Frules%1Fprometheus-prometheus-kube-prometheus-prometheus-rulefiles-0%1Fmonitoring-prometheus-kube-prometheus-postgres-rules-d680d523-8aab-4e4d-9b60-5abc8bb91e0a.yaml%24postgres_alerts%24PostgresDown%24353288546/view?tab=instances).

**Evidence:**

- **Screenshot 1**: Shows the **Grafana Alert Rules** overview where the rule is evaluated.  
  <img src="./assets/grafana-alert-rules-postgres-down.png" style="width: 50%;" alt="Grafana Alert Rules">
- **Screenshot 2**: Displays the **Firing Alert Instance** with the specific label `namespace="dev"`, proving the
  dynamic templating works as intended.   
  <img src="./assets/grafana-postgres-down.png" style="width: 50%;" alt="Grafana Postgres Down">

---

## 8. Security

# !!!WIP!!!

**Security with encrypted protocols**

- Custom Ingress Controller: Deactivated k3s default Traefik to gain full control via a custom Helm-based Traefik
  installation; command used during installation:

```
curl -sfL https://get.k3s.io | sh -s - \
  --disable traefik \
  --write-kubeconfig-mode 644
```

- Automated Certificate Management: Integrated cert-manager to handle the full lifecycle of TLS certificates
- Let's Encrypt Integration: Implemented ACME (HTTP-01) challenges using a ClusterIssuer for automated domain validation
- Environment Strategy:
    - Currently using Let's Encrypt Staging environment for all environment (dev/prod) to avoid API rate limits
    - Configuration is "Production-ready": Switching to the Production Issuer only requires a single annotation change.
- Protocol Security: Automated HTTP-to-HTTPS redirection is enforced at the Ingress level

**Secrets management**

- Database credentials are stored as Kubernetes Secrets
- Secrets are encrypted using SOPS
- Encryption is performed before committing manifests to version control
- Environment variables injected into the database container:
    - POSTGRES_USER
    - POSTGRES_PASSWORD
    - POSTGRES_DB

Implementation details

- SOPS with age key encryption
- Encrypted secrets are stored safely in Git
- Decryption happens only during deployment

Benefits

- Prevents plaintext credentials in the repository

Access isolation

- Database is only accessible inside the Kubernetes cluster
- No public exposure of PostgreSQL service

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

### 9.3 Infrastructure Deployment (IaC) (STATUS: TODO)

#### TODO: Write down commands:

```
# Setup global "infra" config like Traefik, Cert-Manager, ArgoCD, Monitoring
cd infra
terraform init
terraform apply -target=helm_release.cert_manager
terraform apply

# configure SOPS key
mkdir -p ~/.config/sops/age
cp /home/ubuntu/infrastructure/age.key.dist ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# setup DB for namespace dev & prod
cd infrastructure/environments/dev;  terraform init; terraform apply
cd infrastructure/environments/prod; terraform init; terraform apply

# Execute ArgoCD `app-of-apps.yaml`
cd infrastructure
kubectl apply -f argocd/app-of-apps.yaml
```

The deployment is organized into three layers to strictly separate the global platform from environment-specific
resources:

**1. Base Layer (Manual)**: Provisioning of the VM and installation of k3s, SOPS/Age for secret decryption, and the
Terraform CLI.

**2. Global Cluster Services & GitOps Control (infra/)**: Running terraform apply in this folder sets up the cluster's "
Control Plane". This layer is environment-agnostic and manages the global state:

- Traefik & Cert-Manager: Handling ingress and SSL for the entire cluster.
- ArgoCD: Installation of the GitOps Controller.
- ArgoCD Application Resources: Definition of the "App-of-Apps" pattern. Here, the links between the Git repository and
  the various environments (dev, prod) are established.

**3. Application Environments (environments/)**: Running terraform apply in environments/dev or environments/prod
provisions only the dedicated resources for that specific stage:

- Namespace: Logical isolation for the environment.
- Stateful Infrastructure: Provisioning of the Database (PostgreSQL) and the injection of environment-specific secrets (
  e.g., DB credentials) via SOPS.

**4. GitOps Synchronization**: Once the infrastructure is ready, ArgoCD (provisioned in the global layer) detects the
new namespace and its requirements. It automatically synchronizes the stateless applications (Frontend, Backend) and
CronJobs from the charts/ folder into the target namespace.

### 9.4 How to roll back to a previous version

Since the project follows the GitOps principle using ArgoCD, the source of truth is the Git repository.

**Rollback Procedure**:

1) **Git Revert**: Revert the last commit in the Git repository to a known stable state and push the changes.
2) **ArgoCD Sync**: ArgoCD detects the change in Git and automatically synchronizes the cluster to the previous version.
