## Step 6: Automation

- Automate server deployment and configuration (IaC)
    - Terraform used to provision Kubernetes namespaces and Helm releases
    - Ensures consistent environment setup across dev and prod
- Create declarative templates (YAML) to deploy infrastructure, environments and applications
    - Helm charts for frontend, backend and database
    - Kubernetes manifests (deployments, services, statefulsets) defined declaratively
- Use environment variables to secure sensitive data and avoid template redundancy
    - SOPS-encrypted YAML files for DB credentials
    - Environment-specific `values-dev.yaml` / `values-prod.yaml` for Helm charts
- These templates will be reusable and repeatable regardless of the environment deployed
    - Same Helm charts and Terraform setup used for both dev and prod
    - Minimal duplication: only values and secrets differ per environment
