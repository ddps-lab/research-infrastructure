# research-infrastructure
DDPS 연구실 실험 환경을 위한 쿠버네티스 인프라 구축

## 세팅 순서
### 1. Docker, Kubeadm 등 필수 패키지 설치 및 linux 설정
```
source setup.sh
```

### 2. kubeadm init
**Master Node에서 init**
```
sudo kubeadm init \
		--apiserver-advertise-address=0.0.0.0 \
		--pod-network-cidr=<public subnet cidr> \
		--apiserver-cert-extra-sans=<master node public ip> \
		--ignore-preflight-errors=ALL
```

**Worker Node에서 join** <br/>
- Master Node에서 init 완료 시 join에 대한 명령어 확인 후 복사하여 Worker Node에서 실행


### 3. kubectl 설치
**Master Node에서만 진행**
```
source kubectl.sh
```

### 4. CNI 설정
**calico cni 생성**
```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
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
### 쿠버네티스에 배포
```
kubectl apply -f bentoserve.yaml
```
