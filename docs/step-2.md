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

---

### 5. Multi-instance architecture & high availability

- Multi-server architecture is not implemented
- High availability is achieved through multiple pod replicas
- For production:
    - replicaCount is set to 2 for backend services
    - Horizontal Pod Autoscaler (HPA) configuration is defined in Helm values:
        - `minReplicas`, `maxReplicas`, CPU-based scaling

---

### 6. Backup management & disaster recovery (**Status: TODO**)

- unclear requirements  
  => DB dumps can be stored on VM for demo purposes (in real world we would store it externally e.g. AWS S3)  
  => Recovery from a dump can be documented for demo purposes

- Planned topics to address:
    - Database backup strategy
    - Backup storage location
    - Restore and recovery procedures

---

### 7. Frontend environment configuration

- To inject environment-specific variables into the Angular frontend, a dynamic `assets/env.js` file is used
- This file is referenced in `petclinic-angular/src/environments/environment.prod.ts`
- In Kubernetes, the `assets/env.js` is overridden via a ConfigMap per environment
- Example: `REST_API_URL` is dynamically injected for dev / prod environments
- This approach avoids hardcoding environment variables in the application and enables reusable deployments
