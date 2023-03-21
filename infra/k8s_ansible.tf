resource "null_resource" "create_ansible_hosts_txt" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
cat > ansible_hosts.txt <<INNER_EOF
[all:vars]
ansible_user=ubuntu
ansible_ssh_common_args=-o "StrictHostKeyChecking=no"
[all]
[etcd]
[first-kube-master]
[not-first-kube-master]
[kube-master]
[kube-node]
[k8s-cluster:children]
kube-master
kube-node
INNER_EOF
EOF
  }
}

resource "null_resource" "save_first_master_node_ids" {
  triggers = {
    always_run = timestamp()
  }
  count = 1
  depends_on = [
    module.k8s,
    null_resource.create_ansible_hosts_txt
  ]
  provisioner "local-exec" {
    command = <<EOF
sed -i '' '/\[first-kube-master\]/a\
${module.k8s.master_node_names[0]}
' ansible_hosts.txt
EOF
  }
}

resource "null_resource" "save_not_first_master_node_ids" {
  triggers = {
    always_run = timestamp()
  }
  count = length(module.k8s.master_node_ids) - 1
  depends_on = [
    module.k8s,
    null_resource.save_first_master_node_ids
  ]
  provisioner "local-exec" {
    command = <<EOF
sed -i '' '/\[not-first-kube-master\]/a\
${module.k8s.master_node_names[count.index] + 1}
' ansible_hosts.txt
EOF
  }
}

resource "null_resource" "save_master_node_ids" {
  triggers = {
    always_run = timestamp()
  }
  count = length(module.k8s.master_node_ids)
  depends_on = [
    module.k8s,
    null_resource.save_first_master_node_ids
  ]
  provisioner "local-exec" {
    command = <<EOF
sed -i '' '/\[all\]/a\
${module.k8s.master_node_names[count.index]} ansible_host=${module.k8s.master_node_ids[count.index]}
' ansible_hosts.txt
sed -i '' '/\[etcd\]/a\
${module.k8s.master_node_names[count.index]}
' ansible_hosts.txt
sed -i '' '/\[kube-master\]/a\
${module.k8s.master_node_names[count.index]}
' ansible_hosts.txt
EOF
  }
}

resource "null_resource" "save_worker_node_ids" {
  triggers = {
    always_run = timestamp()
  }
  count = length(module.k8s.worker_node_ids)
  depends_on = [
    module.k8s,
    null_resource.save_master_node_ids
  ]
  provisioner "local-exec" {
    command = <<EOF
sed -i '' '/\[all\]/a\
${module.k8s.worker_node_names[count.index]} ansible_host=${module.k8s.worker_node_ids[count.index]}
' ansible_hosts.txt
sed -i '' '/\[kube-node\]/a\
${module.k8s.worker_node_names[count.index]}
' ansible_hosts.txt
EOF
  }
}

resource "time_sleep" "wait_for_connect_ssh" {
  depends_on = [
    null_resource.save_master_node_ids,
    null_resource.save_worker_node_ids
  ]
  create_duration = "1m"
}

resource "null_resource" "initial_setup_for_k8s" {
  depends_on = [
    time_sleep.wait_for_connect_ssh
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible_hosts.txt assets/ansible_k8s/k8s_initial_setup.ansible.yml "
  }
}

resource "null_resource" "create_k8s_cluster" {
  depends_on = [
    null_resource.initial_setup_for_k8s
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible_hosts.txt assets/ansible_k8s/k8s_create_cluster.ansible.yml"
  }
}

resource "null_resource" "join_nodes_to_k8s_cluster" {
  depends_on = [
    null_resource.create_k8s_cluster
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible_hosts.txt assets/ansible_k8s/k8s_join_nodes_to_k8s_cluster.ansible.yml"
  }
}