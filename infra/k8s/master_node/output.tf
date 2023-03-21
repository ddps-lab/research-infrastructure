output "master_node_ids" {
  value = tolist(aws_instance.master_node[*].id)
}

output "master_node_names" {
  value = tolist(aws_instance.master_node[*].tags_all.Name)
}