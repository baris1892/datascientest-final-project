###### some notes (needs to be refactored later)

##### build + push docker images

```
docker tag datascientest-final-project-petclinic-rest:latest baris1892/datascientest-final-project-petclinic-rest:latest
docker tag datascientest-final-project-petclinic-angular:latest baris1892/datascientest-final-project-petclinic-angular:latest

docker push baris1892/datascientest-final-project-petclinic-rest:latest
docker push baris1892/datascientest-final-project-petclinic-angular:latest
```

##### helm commands

```
# helm upgrade frontend
helm upgrade --install frontend ./frontend -f frontend/values.yaml -f frontend/values-dev.yaml  -n dev
helm upgrade --install frontend ./frontend -f frontend/values.yaml -f frontend/values-prod.yaml -n prod

# helm upgrade backend
helm upgrade --install backend ./backend -f backend/values.yaml -f backend/values-dev.yaml  -n dev
helm upgrade --install backend ./backend -f backend/values.yaml -f backend/values-prod.yaml -n prod

# optionally remove database-db-secret so it is properly updated: 
kubectl delete secret database-db-secret -n dev
kubectl delete secret database-db-secret -n prod

# helm upgrade database for dev with secrets
sops -d database/values-secrets-dev.yaml  | helm upgrade --install database database -f database/values.yaml -f - -n dev
sops -d database/values-secrets-prod.yaml | helm upgrade --install database database -f database/values.yaml -f - -n prod

# list all helm deployments
helm list -n dev

# trigger rollout (needed after updating e.g. config map like frontend assets/env.js)
kubectl -n dev rollout restart deployment frontend

```

##### angular app: assets/env.js

to be able to have different env vars for our angular app, we've used
`assets/env.js` which is then referenced in `petclinic-angular/src/environments/environment.prod.ts`.

However, the `assets/env.js` will be overriden via k8s ConfigMap so we can inject
dynamically different `REST_API_URL`.

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
