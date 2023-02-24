sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get install -y kubelet kubeadm kubectl docker

# 패키지 버전 홀드 (업데이트에서 제외)
sudo apt-mark hold kubelet kubeadm kubectl docker
