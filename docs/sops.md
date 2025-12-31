##### SOPS

Install sops:

```
curl -Lo sops https://github.com/getsops/sops/releases/download/v3.11.0/sops-v3.11.0.linux.amd64
chmod +x sops
sudo mv sops /usr/local/bin/
```

Install age (for key generation):

```
sudo apt install -y age
```

Configure Age Key:

```
mkdir -p ~/.config/sops/age

echo "AGE-SECRET-KEY-XXX" > ~/.config/sops/age/keys.txt

chmod 600 ~/.config/sops/age/keys.txt
```

encrypt file:

```
sops -e -i charts/database/values-secrets-dev.yaml
sops -e -i charts/database/values-secrets-prod.yaml
```

Check values after deploying k8s secret:

```
kubectl get secret database-db-secret -n dev -o json | jq -r '.data | map_values(@base64d)'
```

**Note:** `age.key.dist` was added on purpose to the repository for demonstration purposes.
