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
------

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
------

# Storage

## Persistent Volumes and Persistent Volumes Claims
```sh
kubectl get pv
kubectl get pvc
```