#k8s node를 위한 기본 설정
modprobe br_netfilter
echo "br_netfilter" >> /etc/modules-load.d/k8s.conf

cat > /etc/sysctl.d/k8s.conf <<EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
sysctl --system

#containerd 기본 설정
apt update -y
apt install -y containerd

mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

#k8s 기본 설정
apt install -y apt-transport-https ca-certificates curl
#k8s apt source 추가
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update -y
#k8s 관리를 위한 최소 패키지 3종, containerd 설치
apt install -y kubelet kubeadm kubectl

#crictl 기본 설정
cat > /etc/crictl.yaml << EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: true
EOF