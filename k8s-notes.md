# Pod

## Imperative
```sh
kubectl run web --image=nginx
```
```sh
kubectl run client --image=busybox --command -- bin/sh -c "sleep 100000"
```
僅能建立單一<containerd>

## Declarative
```sh
kubectl apply -f nginx.yml
```
建立multi<containerd>

## kubectl dry-run

### Server-side
```sh
kubectl apply -f nginx.yml --dry-run=server
```
### Client-side
```sh
kubectl apply -f nginx.yml --dry-run=client
```
```sh
kubectl run web --image=nginx --dry-run=client -o yaml
```
```sh
kubectl run web --image=nginx --dry-run=client -o yaml > nginx.yml
```

## kubectl diff
比較目前運行與新yaml有什麼差異
```sh
kubectl diff -f new-nginx.yml
```

## Pod的基本操作
```sh
kubectl get pods
```
```sh
kubectl get pods client
```
```sh
kubectl delete pod web
```
詳述pod內容
```sh
kubectl describe pod my-pod
``` 
## 登入Container中
登入容器中
```sh
kubectl exec client -- date
```
查詢
```sh
kubectl exec client -it -- sh
```
指定登入(多容器中)
```sh
kubectl exec my-pod -c
```
```sh
kubectl exec my-pod -c nginx -- date
```

## API level log
--watch 持續監聽kubectl
```sh
kubectl get pod <pod-name> -v 6
kubectl get pods <pod-name> --watch -v 6
```
後臺執行事件日誌
```sh
kubectl get events -w &
```

## kubectl proxy
透過proxy才能直接訪問k8s api
後臺執行
```sh
kubectl proxy &
```
通过proxy来访问API了，例如
```sh
curl http://127.0.0.1:8001/api/v1/namespaces?limit=500
```
## Static Pod
Managed by the kubelet on Node  
kubelet’s configuration, by default is `/etc/kubernetes/manifests`  
kubelet configuration file: `/var/lib/kubelet/config.yaml`  

## Namespace
```sh
kubectl get ns
kubectl describe ns
kubectl get ns -A
kubectl create namespace demo
kubectl delete namespaces demo
```
## Change default namespace
查看
```sh
kubectl config get-contexts
```
切換default到ns demo
```sh
kubectl config set-context --current --namespace demo
```
------

# Controller and Deployment

## Labels
show
```sh
kubectl get nodes --show-labels
```
add
```sh
kubectl label nodes k8s-worker hardware=local_gpu
```
delete
```sh
kubectl label nodes k8s-worker1 hardware-
```

## 控制關係
Deployment 	&rarr; ReplicaSets 	&rarr; pods

## Imperative
```sh
kubectl create deployment web --image=nginx
```
擴充
```sh
kubectl scale deployment web --replicas 5
```

## Declarative
```sh
kubectl create deployment web --imgae=nginx --dry-run=client -o yaml > deploy-web.yaml
kubectl apply -f deploy-web.yaml
```
擴充
```sh
kubectl edit deployments.apps web
```
Update image
```sh
kubectl set image delpoyment/web nginx=nginx=1.26.0
```

## Rolling Back
查看history
```sh
kubectl rollout history deployment web
```
回滾編號
```sh
kubectl rollout undo deployment web --to-revision=1
```
## DaemonSet

## Deployment vs DaemonSet

| 特性 | Deployment | DaemonSet |
| --- | --- | --- |
| **用途** | 管理普通應用程序的 Pod 副本 | 確保每個節點上都有一個 Pod 副本 |
| **Pod 副本數量** | 根據 `replicas` 設置數量 | 集群中的每個節點都有一個 Pod 副本 |
| **使用情境** | 適合 Web 應用、API 服務等 | 適合日誌收集、監控代理、網絡代理等 |
| **滾動更新** | 支持滾動更新 | 支持滾動更新 |
| **擴展性** | 可以根據需要動態增加或減少 Pod 副本 | 無法動態調整 Pod 數量，Pod 副本數等於節點數量 |
| **容錯性** | 根據 `replicas` 的設置保證高可用性 | 每個節點都有一個 Pod，保證每個節點的服務運行 |

---

# Scheduling

## Node Selector
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
spec:
  containers:
  - name: hello-world
    image: nginx
  nodeSelector:
    hardware: local_gpu
```
## Affinity and Anti-Affinity

## Taints and Tolerations
```sh
kubectl taint nodes k8s-worker1 key1=value1:NoSchedule
kubectl taint nodes k8s-worker1 key1=value1:NoSchedule-
```

## Cordoning

### cordoning
標記某個節點成為unschedulable，使新pod不會被佈署於此節點，但已運行不受影響。
```sh
kubectl cordon <node_name>
```
常用於維護時段

### drain
使pod服務在節點上gracefully停止
```sh
kubectl drain <node name> --ignore-daemonsets
```

### uncordon
取消標記

## Manual Scheduling
指定效果無視'taint'及'cordon'，強制佈署與指定節點。
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
spec:
   nodeName: 'k8s-worker1'
   containers:
    - name: nginx-container
      image: nginx:latest
```

------

# Storage

## Persistent Volumes and Persistent Volumes Claims
```sh
kubectl get pv
kubectl get pvc
```

# Networking

# Security

## Certificates and kubeconfig files

預設憑證位置</etc/kubernetes/pki/>
curl https//10.0.101.31:6443 --cacert /etc/kubernetes/pki/ca.crt
curl https//10.0.101.31:6443 --insecure

取得憑證資料
```sh
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}'
```
取得憑證資料並解碼
```sh
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' |base64 decode
```
此資料與</etc/kubernetes/pki/ca.crt>相同

用戶證書
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' |base64 --decode > client.crt
kubectl config view --raw -o jsonpath='{.users[0].user.client-key-data}' |base64 --decode > client.key

curl https//10.0.101.31:6443 --cacert /etc/kubernetes/pki/ca.crt --cert client.crt --key client.key

## Role Based Access Control

### Roles
Roles定義腳色操作權限，且切分Namespace
```sh
kubectl create role demorole --verb=get,list --resource=pods,deployment --namespace ns1
kubectl create role demorole --verb=* --resource=pods --namespace ns1
```
- --verb=get,list：這些是允許的操作，代表查看 (get) 和列出 (list)。
- --resource=pods,Deployment：資源類型是Pods及Deployment。
- --namespace=ns1：此 Role 限定在命名空間 ns1 中

## ClusterRoles
Cluster的權限操作，跨越Namespace
```sh
kubectl create clusterrole democlusterrole --verb=get,list --resource=nodes
```

## RoleBinding/ClusterRoleBinding

### RoleBinding
將腳色與用戶綁定
```sh
kubectl create rolebinding demorolebinding --role=demorole --user=demouser --namespace ns1
```
### ClusterRoleBinding
將腳色與用戶綁定
```sh
kubectl create clusterrolebinding democlusterrolebinding --clusterrole=democlusterrole --user=demouser
```

#### Checking way
```sh
kubectl auth can-i list pod --as demouser
kubectl auth can-i list pod --as demouser --namespace ns1
```

## ServiceAccount
一種特殊帳戶，專門用來為Pod提供身份驗證和授權的方式。它允許應用程式（運行在 Pod 中）與 Kubernetes API 進行交互，例如查詢資源、創建資源、更新資源等。  
### 建立ServiceAccount
```sh
kubectl create serviceaccount demo-sa
```
### 配置於pod中
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: client
spec:
   serviceAccount: demosa
   containers:
   - name: client
     image: xiaopeng163/net-box:latest
     command:
      - sh
      - -c
      - "sleep 1000000"
```
### ServiceAccount Authorization添加
```sh 
kubectl create role demorole --verb=get,list --resource=pods
kubectl create rolebinding demorolebinding --role=demorole --serviceaccount=default:demo-sa
```
#### checking way
```sh
kubectl auth can-i list pods --as=system:serviceaccount:default:demo-sa
```

# Maintaining Kubernetes Clusters

## etcd backup and restore operations

### Snapshot using etcdctl
```sh
sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /var/lib/dat-backup.db
```
- snapshot save <backup-file-location>，建議存於異地

### Snapshot status
```sh
sudo etcdctl --write-out=table snapshot status /var/lib/dat-backup.db
```
- </var/lib/dat-backup.db>依照檔案路徑配置

### Restoring etcd with etctl
```sh
sudo ETCDCTL_API=3 etcdctl snapshot restore /var/lib/dat-backup.db --data-dir /var/lib/etcd
```

## Upgrading an existing Cluster (未驗證)
- 只能小版本分位更新
 1.24 &rarr; 1.25
[changlog]https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG

### Upgrade Control Plane (master)
```sh
# update kubeadm
TARGET_VERSION = 1.3.2.X
sudo apt-get update
sudo apt-cache madison kubeadm
sudo apt-mark unhold kubeadm &&\
sudo apt-get update && sudo apt-get install -y kubeadm=$TARGET_VERSION &&\
sudo apt-mark hold kubeadm

# drain master node
kubectl drain k8s-master --ignore-daemonsets

sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v$TARGET_VERSION

# uncordon
kubectl uncordon k8s-master

# update kubelet and kubectl
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet=$TARGET_VERSION kubectl=$TARGET_VERSION && \
sudo apt-mark hold kubelet kubectl
# restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```
### Upgrade work node (worker)
```sh
# go to master node
kubectl drain k8s-worker1 --ingore-daemonsets

# go to node and update kubeadm
TARGET_VERSION = 1.3.2.X
sudo apt-get update
sudo apt-cache madison kubeadm
sudo apt-mark unhold kubeadm &&\
sudo apt-get update && sudo apt-get install -y kubeadm=$TARGET_VERSION &&\
sudo apt-mark hold kubeadm

sudo kubeadm upgrade node

# update kubelet
sudo apt-mark unhold kubelet && \
sudo apt-get update && sudo apt-get install -y kubelet=$TARGET_VERSION && \
sudo apt-mark hold kubelet 
# restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# go to master node, uncordon this node
kubectl uncordon k8s-worker1
```

## Cluster Cert Renew
- k8s cluster內部通訊Cert有效為1年，到期後須更新
- 錯誤訊息: x509: certificate has expired or is not yet valid
### Checking Cert Expired Date
```sh
sudo kubeadm certs check-expiration
```
### Renew Cert
建議etcd snapshot
```sh
sudo kubeadm certs renew all
```
完成後須重啟kube-apiserver, kube-controller-manager, kube-scheduler和etcd。

---
# Logging and Monitoring

## Logging

### logs排查資料流
kubectl logs &rarr; API Server &rarr; kubelet &rarr; container logs

### kubectl logs
```sh
#basic
kubectl logs $POD_NAME
#multi-container pod
kubectl logs $POD_NAME -c $CONTAINER_NAME
#all containers
kubectl logs $POD_NAME --all-containers
#label select
kubectl logs --selector app=demo
#follow lastest logs
kubectl logs -f $POD_NAME
#get last 5 entries logs
kubectl logs $POD_NAME --tail 5
```
# API Server
- kubectl異常呼叫不到api時可排查方法
```bash
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock logs $CONTAINER_ID
```
或是
```sh
sudo tail /var/log/containers/$CONTAINER_NAME_$CONTAINER_ID
```
### kubelet logs
```sh
systemctl status kubelet.service  
journalctl -u kubelet.service --no-pager
journalctl -u kubelet.service | grep -i ERROR
journalctl -u kubelet.service --since today --no-pager
```

## Events

### Global
```sh
kubectl get events
#篩選
kubectl get events --field-selector type=Warning,reason=Failed
#run `fg` and ctrl +c to break it
kubectl get events --watch &  
```
### Per Resource
```sh
kubectl describe pods nginx
```

## Monitoring
- 需安裝Metrics Server套件
查看CPU、Memory
```sh
kubectl top pods
kubectl top nodes
```

# Others

## JsonPath
```sh
# 獲取containers names
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# 獲取containers image資訊
kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}'

# 跨行
kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}{"\n"}'

# ?() filter篩選
# @ - the current object
kubectl get nodes -o jsonpath="{.items[*].status.addresses[?(@.type=='InternalIP')].address}"

# sorting排序
kubectl get pods -A -o jsonpath='{.items[*].metadata.name}{"\n"}' --sort-by=.metadata.name
```