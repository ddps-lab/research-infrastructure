# research-infrastructure
DDPS 연구실 실험 환경을 위한 쿠버네티스 인프라 구축

## 세팅 순서
### 1. Docker, Kubeadm 등 필수 패키지 설치 및 linux 설정
```
source setup.sh
```
### 2. kubelet 설치를 위한 세팅
```
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo mkdir -p /etc/containerd
```

```
sudo vim /etc/containerd/config.toml
```
위의 파일 내용 중 SystemdCgroup = true로 변경

```
sudo systemctl restart containerd
```

### 3. kubelet 설치
```
source kubelet.sh
```

## Docker 환경 설정 변경
  - Docker service 파일 변경
    ```
    sudo vi /lib/systemd/system/docker.service
    ```
  - ExecStart 구문 뒤에 systemd 관련 명령어 추가
    ```
    [Service]
    Type=notify                                                                    
    # the default is not to use systemd for cgroups because the delegate issues still
    # exists and systemd currently does not support the cgroup feature set required
    # for containers run by docker                                                
    ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd
    ExecReload=/bin/kill -s HUP $MAINPID
    TimeoutSec=0
    RestartSec=2
    Restart=always
    ```
- Docker 설정 반영
  ```
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  ```
