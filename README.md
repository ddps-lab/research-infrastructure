# research-infrastructure
DDPS 연구실 실험 환경을 위한 쿠버네티스 인프라 구축

## Docker 환경 설정 변경
- ExecStart 구문 뒤에 systemd 관련 명령어 추가
  ```
  sudo vi /lib/systemd/system/docker.service
  ```
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
