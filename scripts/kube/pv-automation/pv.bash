# /bin/bash

PVs=$(kubectl get pv -o json | jq -r '.items[] | {pvName:.metadata.name, Capacity:.spec.capacity.storage, AccessMode:.spec.accessModes[0], NameSpace: .spec.claimRef.namespace, Name: .spec.claimRef.name, storageClass: .spec.storageClassName, creationTimeStamp: .metadata.creationTimestamp, claimPolicy: .spec.persistentVolumeReclaimPolicy}')
# echo "$PVs" | sed 's/}\s*\{/}, {/g' > pv.json
echo "$PVs" > pv.json
# sed -i -E 's/}\n\{/}, {/g' pv.json
sed -i -E 's/}\s*\{/}, {/g' pv.json


