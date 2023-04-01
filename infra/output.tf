output "master_node_ids" {
  value = module.k8s.master_node_ids
}

output "worker_node_ids" {
  value = module.k8s.worker_node_ids
}