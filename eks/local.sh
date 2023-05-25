export CLUSTER_NAME=<cluster-name>
    
export KARPENTER_VERSION=v0.27.3
    
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text)"
    
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)