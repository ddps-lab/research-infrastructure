# research-infrastructure
DDPS 연구실 실험 환경을 위한 쿠버네티스 인프라 구축

## 세팅 순서
### 1. Docker, Kubeadm 등 필수 패키지 설치 및 linux 설정
```
sudo su
source infra/setup.sh
```

### 2. kubeadm init
```
publicip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sudo kubeadm init \
		--apiserver-advertise-address=0.0.0.0 \
		--pod-network-cidr=172.16.0.0/16  \
		--apiserver-cert-extra-sans=$publicip
```

**Worker Node에서 join** <br/>
- Master Node에서 init 완료 시 join에 대한 명령어 확인 후 복사하여 Worker Node에서 실행


### 3. kubectl 설정
**Master Node에서만 진행**
**Root 계정에서 작업시**
```
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.profile
source ~/.profile
```
**일반 사용자에서 작업시**
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 4. CNI 설정
**calico cni 생성**
```
#calico 설치
calico_version="v3.25.0"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$calico_version/manifests/calico.yaml

#kubectl-calico 설치
arch="arm64"
curl -L https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-$arch -o kubectl-calico
mv kubectl-calico /usr/bin
chmod +x /usr/bin/kubectl-calico
```

**flannel cni 생성**
```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```
**에러 발생시**
```
sudo vim /run/flannel/subnet.env
```
해당 내용 추가
```
FLANNEL_NETWORK=10.244.0.0/16 // 게이트웨이
FLANNEL_SUBNET=10.244.0.1/24 // 서브넷
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
```

## Inference Serving 서버 구동
### bentoml 프레임워크 설치
```
pip install bentoml
```
### bentoml 기반 도커 이미지 빌드
```
bentoml build

bentoml containerize <name:tag>
```
**메모리 관련 에러 발생시**
```
docker builder prune --filter type=exec.cachemount
docker volume prune
```

### 쿠버네티스에 배포
```
kubectl apply -f bentoserve.yaml
```
