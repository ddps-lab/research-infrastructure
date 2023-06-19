### 이 구성 파일들은 macOS를 기준으로 작성되었습니다.
### 현재는 AWS를 기준으로 작성되었습니다.
### Windows에서는 Ansible을 실행할 수 없기 때문에, 이 자동화 SW를 사용할 수 없습니다.
<br>

# 기본 구성
## 1. Install required packages
```shell
#If you don't have Homebrew installed, install it.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#Install packages
brew install terraform ansible awscli
brew install --cask session-manager-plugin
```

## 2-a. ~/.ssh/config setting for SSH connection using session manager
```shell
#add below texts in ~/.ssh/config!
#replace <AWS PROFILE NAME> ex) default
Host i-* mi-*
  ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile <AWS PROFILE NAME>"
```
## 2-b-1. ~/.ssh/config setting for SSH connection using session manager with ssh agent (preferred)

```shell
#add below texts in ~/.ssh/config!
#replace <AWS PROFILE NAME> ex) default
Host i-* mi-*
  ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile <AWS PROFILE NAME>"
  AddKeysToAgent yes
  UseKeyChain yes
  ForwardAgent yes
```

## 2-b-2. Add SSH Key to keychain
```shell
ssh-add -K '<KEY PATH>'
```

## 3. Create EC2 Key Pair on your prefer region.

## 4. Set AWS CLI Profile
```shell
aws configure --profile <AWS PROFILE NAME>
AWS Access Key ID: <ACCESS KEY> # must be specified
AWS Secret Access Key: <SECRET ACCESS KEY> # must be specified
Default region name: <REGION> # must be specified
...
```
<br>

# Terraform variable 설정

## 1. Set main variables in variables.tf
#### variables.tf에서는 아래와 같은 내용을 설정할 수 있습니다.
- main_suffix (string) : 생성되는 리소스 Name tag 맨 앞에 붙을 문자열을 지정합니다. 이와 관련해서는 main.tf의 module.k8s의 cluster_prefix와 module.vpc의 vpc_name을 참고합니다.
- region (string) : Kubernetes Clsuter를 생성할 AWS Region을 지정합니다. 기본 값은 **"ap-northeast-2" (서울)**입니다.
- awscli_profile (string) : AWS CLI의 profile name을 지정합니다.

## 2. Set VPC variables in vpc_variables.tf
#### vpc_variables.tf에서는 아래와 같은 내용을 설정할 수 있습니다.
- vpc_cidr (string) : VPC의 CIDR을 지정합니다. 기본 값은 **"192.168.0.0/16"** 입니다.
- public_subnet_cidrs (list(string)) : Public Subnet의 CIDR들을 지정합니다. 기본 값은 **["192.168.10.0/24"]**입니다. list에 CIDR을 지정한만큼 생성됩니다.
- private_subnet_cidrs (list(string)) : Private Subnet의 CIDR들을 지정합니다. 기본 값은 **["192.168.12.0/24"]**입니다. list에 CIDR을 지정한만큼 생성됩니다.

## 3. Set Kubernetes variables in k8s_variable.tf
#### k8s_variable.tf에서는 아래와 같은 내용을 설정할 수 있습니다.
- instance_type (string): Kubernetes Cluster의 EC2 Instance의 Instance Type을 지정합니다.
- key_name (string) : Kubernetes Cluster의 EC2 Instance와 NAT Instance의 EC2 Key Pair를 지정합니다.
- master_node_number (number) : 생성할 Kubernetes master node의 개수를 지정합니다. 기본 값은 **1**입니다.
- worker_node_number (number) : 생성할 Kubernetes worker node의 개수를 지정합니다. 기본 값은 **1**입니다.