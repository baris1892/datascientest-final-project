## Step 3: Data Management

### 1. Choose the right technical data storage solution

Chosen solution

- Relational database: PostgreSQL
- Deployment type: Kubernetes StatefulSet
- Persistence: PersistentVolumeClaim (PVC)

Rationale

- PostgreSQL is well suited for structured, transactional application data
- StatefulSet guarantees:
    - Stable network identity
    - Stable volume attachment per replica

Storage backend

- Kubernetes distribution: k3s
- Default StorageClass: local-path
- Provisioner: rancher.io/local-path
- Storage type: node-local filesystem

Trade-offs

- ✅ Survives pod restarts and cluster restarts
- ❌ No high availability in case of node failure
- ❌ Node-bound storage (acceptable for this project)

---

### 2. Create a database to store application data

Implementation

- PostgreSQL deployed via Helm chart
- Database runs as a single-replica StatefulSet
- Persistent volume attached using volumeClaimTemplates

StatefulSet excerpt:

```
volumeMounts:
  - name: data
    mountPath: /var/lib/postgresql/data

volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: local-path
      resources:
        requests:
          storage: 1Gi
```

Result

- Database files are stored outside the container lifecycle
- Data persists independently of pod restarts or rescheduling

---

### 3. Persistence & restart validation

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

### 5. Set up access rights

Secrets management

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

### 6. Data ingestion

Ingestion flow

- Application services write data to PostgreSQL
- Data ingestion happens via REST APIs exposed by spring backend service
- PostgreSQL acts as the system of record

---

### 7. Data consumption & log management

Data consumption

- Backend service reads/writes application data from PostgreSQL

Log management

- Logs collected via Kubernetes logging mechanisms
- Application logs separated from persistent database storage

---

### Conclusion

- Persistent PostgreSQL database successfully deployed with Kubernetes primitives
- Data survives pod and cluster restarts
- Secrets managed securely with SOPS
- Storage usage controlled via explicit PVC requests
