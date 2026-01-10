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

##### Useful commands

cd environments/dev/; terraform apply --auto-approve; cd ../../infra; terraform apply --auto-approve; cd ..
cd environments/prod/; terraform apply --auto-approve; cd ../../infra; terraform apply --auto-approve; cd ..

#### Trigger k8s cronjob manually

```
kubectl -n dev create job --from=cronjob/database-backup manual-backup-test
kubectl -n dev get pods         # ==> "manual-backup-test-XXX" should exist
kubectl -n dev logs -f -l job-name=manual-backup-test

# delete manually created job again 
kubectl -n dev delete job manual-backup-test
```