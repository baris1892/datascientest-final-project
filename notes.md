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
helm upgrade --install frontend ./frontend --namespace dev
helm upgrade --install database ./database --namespace dev
helm upgrade --install backend  ./backend  --namespace dev


helm upgrade --install frontend ./frontend \
  -f ./frontend/values.yaml \
  -f ./frontend/values-dev.yaml \
  --namespace dev



helm list -n dev

```

##### angular app: assets/env.js

to be able to have different env vars for our angular app, we've used
`assets/env.js` which is then referenced in `petclinic-angular/src/environments/environment.prod.ts`.

However, the `assets/env.js` will be overriden via k8s ConfigMap so we can inject
dynamically different `REST_API_URL`.

