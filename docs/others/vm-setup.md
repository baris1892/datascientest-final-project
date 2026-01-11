## Setup for Proxmox VM

Run the following commands in Proxmox VM.

#### Install docker

```
# Update package index
apt update

# Install prerequisite packages
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Install Docker from Debian’s default repo
apt install -y docker.io

# Verify Docker installation
docker --version

# Enable and start Docker service
systemctl enable docker
systemctl start docker
systemctl status docker
```

#### Install k3s without pre-installed traefik:

```
curl -sfL https://get.k3s.io | sh -s - \
  --disable traefik \
  --write-kubeconfig-mode 644
  
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
chown $USER:$USER ~/.kube/config
```

---

#### Install Terraform

```
# Set version variable
TERRAFORM_VERSION="1.10.3"

# Download Terraform binary
curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install unzip if not present
apt update
apt install -y unzip

# Unzip and move to /usr/local/bin
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/

# Verify installation
terraform -version

# Clean up
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
```

---

#### Install Age

Age is necessary for SOPS decryption

```
apt update
apt install -y age
age --version

mkdir -p ~/.config/sops/age
cp /home/ubuntu/infrastructure/age.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

#### Install SOPS

```
curl -L -o sops-v3.11.0.linux.amd64 https://github.com/getsops/sops/releases/download/v3.11.0/sops-v3.11.0.linux.amd64
mv sops-v3.11.0.linux.amd64 /usr/local/bin/sops
chmod +x /usr/local/bin/sops
```

---

#### Execute `terraform apply` for `infra` folder

```
cd infra
terraform init
terraform apply
kubectl apply -f issuers-staging.yaml
```

---

#### Execute ArgoCD `app-of-apps.yaml`

```
cd infrastructure
kubectl apply -f argocd/app-of-apps.yaml

# show argocd registered application
kubectl -n argocd get applications

# force refresh
kubectl -n argocd annotate application root         argocd.argoproj.io/refresh=hard --overwrite
kubectl -n argocd annotate application frontend-dev argocd.argoproj.io/refresh=hard --overwrite

# describe argocd application
kubectl -n argocd describe applications frontend-dev

# get deployed image
kubectl -n dev get deploy frontend -o=jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

# get argocd UI password (username is always 'admin')
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 
```
