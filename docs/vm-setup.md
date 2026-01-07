#### Install k3s without pre-installed traefik and serviceLB (load balancer):

```
curl -sfL https://get.k3s.io | sh -s - \
  --disable traefik \
  --write-kubeconfig-mode 644
  
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
```

---

#### Install Terraform

```
sudo snap install terraform --classic
terraform -version
```

---

#### Install Age

Age is necessary for SOPS decryption

```
sudo apt update
sudo apt install -y age
age --version

mkdir -p ~/.config/sops/age
cp /home/ubuntu/infrastructure/age.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

#### Install SOPS

```
cd /tmp
curl -L -o sops-v3.11.0.linux.amd64 https://github.com/getsops/sops/releases/download/v3.11.0/sops-v3.11.0.linux.amd64
sudo mv sops-v3.11.0.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops
```

---

#### Execute `terraform apply` for `infra` folder

```
cd infra
terraform init
terraform apply
kubectl apply -f infra/issuers-staging.yaml
```

---

###### Other Notes

- Remove terraform state on VM:  
  Inside desired folder execute:

```
rm -rf .terraform
rm -rf .terraform.lock.hcl
```
