#!/bin/bash

echo -e "\033[34m[TASK 1] Disable and turn off SWAP\033[0m"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo -e "\033[34m[TASK 2] Install some tools\033[0m"
apt install -y jq iputils-ping net-tools >/dev/null 2>&1

echo "\033[34m[TASK 3] Enable and Load Kernel modules\033[0m"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo -e "\033[34m[TASK 4] Add Kernel settings\033[0m"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

echo -e "\033[34m[TASK 5] Install containerd runtime\033[0m"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt -qq update >/dev/null 2>&1
apt install -qq -y containerd.io >/dev/null 2>&1
containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1

echo -e "\033[34m[TASK 6] Add apt repo for kubernetes\033[0m"
apt-get install -y apt-transport-https ca-certificates curl gpg >/dev/null 2>&1
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

echo -e "\033[34m[TASK 7] Install kubernetes tools\033[0m"
apt-get update >/dev/null 2>&1
apt-get install -y kubelet kubeadm kubectl >/dev/null 2>&1
apt-mark hold kubelet kubeadm kubectl >/dev/null 2>&1

echo -e "\033[34m[TASK 8] Remove shell script files\033[0m"
rm -f install-k8s.sh

echo -e "\033[34m===============Automatic installation completed===============\033[0m"
