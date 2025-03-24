# K8S Notes

# Pod

## How to create a pod?

### Imperative
kubectl run web --image=nginx
kubectl run client --image=busybox --command -- bin/sh -c "sleep 100000"

僅能建立單一containerd

### Declarative
kubectl apply -f nginx.yml

建立多個containerd

------

## kubectl dry-run

### Server-side
kubectl apply -f nginx.yml --dry-run=server

### Client-side
kubectl apply -f nginx.yml --dry-run=client
kubectl run web --image=nginx --dry-run=client -o yaml
kubectl run web --image=nginx --dry-run=client -o yaml > nginx.yml

## kubectl diff
比較目前運行與新yaml有什麼差異
kubectl diff -f new-nginx.yml

## Pod的基本操作
kubectl get pods
kubectl get pods client
kubectl delete pod web
詳述pod內容
kubectl describe pod my-pod
 
## 登入Container中
kubectl exec client -- date
登入容器中
kubectl exec client -it -- sh
查詢
kubectl exec my-pod -c
指定登入(多容器中)
kubectl exec my-pod -c nginx -- date

## API level log
kubectl get pod <pod-name> -v 6
--watch 持續監聽kubectl
kubectl get pods <pod-name> --watch -v 6
後臺執行事件日誌
kubectl get events -w &

------

#kubectl proxy
透過proxy才能直接訪問k8s api
後臺執行
kubectl proxy &
通过proxy来访问API了，例如
curl http://127.0.0.1:8001/api/v1/namespaces?limit=500

# Namespace
kubectl get ns
kubectl describe ns
kubectl get ns -A
kubectl create namespace demo
kubectl delete namespaces demo
##Change default namespace
查看
kubectl config get-contexts
切換default到ns demo
kubectl config set-context --current --namespace demo

------
# Deployment

### 控制關係
Deployment -> ReplicaSets -> pods

###replicas
kubectl scale deployment web --replicas 5
kubectl edit deployments.apps web
###rollout
kubectl edit deployments.apps web
kubectl rollout history deployment web
kubectl rollout undo deployment web --to-revision=1

## Labels
show
kubectl get nodes --show-labels
add
kubectl label nodes k8s-worker hardware=local_gpu
delete
kubectl label nodes k8s-worker1 hardware-

#Scheduling

## Node Selector

## Affinity and Anti-Affinity

##Taints and Tolerations
kubectl taint nodes k8s-worker1 key1=value1:NoSchedule
kubectl taint nodes k8s-worker1 key1=value1:NoSchedule-

# Storage

## Persistent Volumes and Persistent Volumes Claims
kubectl get pv
kubectl get pvc
