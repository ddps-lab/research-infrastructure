resource "null_resource" "save_ansible_hosts_txt" {
  depends_on = [
    module.k8s
  ]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "python3 create_ansible_hosts.py '${jsonencode(module.k8s.master_node_names)}' '${jsonencode(module.k8s.master_node_ids)}' '${jsonencode(module.k8s.worker_node_names)}' '${jsonencode(module.k8s.worker_node_ids)}'"
  }

}

resource "time_sleep" "wait_for_connect_ssh" {
  depends_on = [
    null_resource.save_ansible_hosts_txt
  ]
  create_duration = "1m"
}

resource "null_resource" "initial_setup_for_k8s" {
  depends_on = [
    time_sleep.wait_for_connect_ssh
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible_hosts.txt assets/ansible_k8s/k8s_initial_setup.ansible.yml"
  }
}

resource "null_resource" "create_k8s_cluster" {
  depends_on = [
    null_resource.initial_setup_for_k8s
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible_hosts.txt assets/ansible_k8s/k8s_create_cluster.ansible.yml --extra-vars 'CLUSTER_NAME=${var.main_suffix}-k8s'"
  }
}

resource "null_resource" "join_nodes_to_k8s_cluster" {
  depends_on = [
    null_resource.create_k8s_cluster
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible_hosts.txt assets/ansible_k8s/k8s_join_nodes_to_k8s_cluster.ansible.yml --extra-vars 'CLUSTER_NAME=${var.main_suffix}-k8s'"
  }
}

resource "null_resource" "configure_monitoring" {
  depends_on = [
    null_resource.join_nodes_to_k8s_cluster
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible_hosts.txt assets/ansible_k8s/k8s_configure_monitoring.ansible.yml"
  }
}

resource "null_resource" "when_destroy" {
  provisioner "local-exec" {
    when = destroy
    command = "ansible-playbook -i ansible_hosts.txt assets/ansible_k8s/k8s_delete_nginx_ingress_controller.ansible.yml"
    on_failure = continue
  }
  depends_on = [
    module.k8s
  ]
}
