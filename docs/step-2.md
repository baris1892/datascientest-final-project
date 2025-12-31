## Step 2 – Infrastructure

### 1. Containerization & Orchestration

- Each application component (frontend, backend, database) is containerized using Docker
- Custom Dockerfiles are used for:
    - Frontend: Angular application
    - Backend: Spring Boot application
- Kubernetes is used as the orchestration platform (k3s)
- Helm charts are created and maintained for:
    - frontend
    - backend
    - database
- Helm enables reusable, parameterized and environment-specific deployments (dev / prod)

---

### 2. Choice of infrastructure components (Front, Back, DB)

- Frontend
    - Angular application
    - Deployed as a Kubernetes Deployment
    - Exposed via Kubernetes Ingress
- Backend
    - Spring Boot (Petclinic) REST API
    - Deployed as a Kubernetes Deployment
    - Communicates internally with the database via ClusterIP service
- Database
    - PostgreSQL
    - Deployed as a Kubernetes Stateful component
    - Database credentials are encrypted using SOPS with an age key
    - Encrypted secrets are decrypted at deploy time and stored as Kubernetes Secrets
- The architecture follows a clear separation of concerns between presentation, business logic, and persistence layers

---

### 3. Network management & connection ports

- Internal communication uses Kubernetes ClusterIP services
- External access is handled via Kubernetes Ingress (Traefik)
- No direct NodePort exposure for application services
- Environment-based domain routing:
    - DEV
        - Frontend: https://dev.baris.cloud-ip.cc
        - Backend API: https://dev-api.baris.cloud-ip.cc
    - PROD
        - Frontend: https://baris.cloud-ip.cc
        - Backend API: https://api.baris.cloud-ip.cc
- This setup ensures controlled access and clean separation between environments

---

### 4. Security with encrypted protocols

- The cluster uses the default Traefik installation provided by k3s.
- TLS certificates are currently managed by Traefik default certificates.
- Let’s Encrypt integration is not yet implemented due to k3s Traefik constraints.
- **Status: TODO / In discussion with project mentor**
- **Planned improvement: Proper HTTPS termination using Let’s Encrypt (or cert-manager)**
- Questions:
    - k3s without traefik pre installed => install own traefik to get TLS/Let's Encrypt running?

---

### 5. Multi-instance architecture & high availability

- Multi-server architecture is not implemented
- High availability is achieved through multiple pod replicas
- For production:
    - replicaCount is set to 2 for backend services
    - Horizontal Pod Autoscaler (HPA) configuration is defined in Helm values:
        - `minReplicas`, `maxReplicas`, CPU-based scaling

---

### 6. Backup management & disaster recovery

- **Status: TODO** (unclear requirements)
- Planned topics to address:
    - Database backup strategy
    - Backup storage location
    - Restore and recovery procedures
- Questions:
    - DB Recovery Plan (where to store DB Dump? AWS S3? )