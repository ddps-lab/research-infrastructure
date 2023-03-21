output "worker_node_ids" {
  value = tolist(aws_instance.worker_node[*].id)
}

output "worker_node_names" {
  value = tolist(aws_instance.worker_node[*].tags_all.Name)
}