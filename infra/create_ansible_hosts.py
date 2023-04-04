import sys
import json

default_text = [
"[all:vars]",
"ansible_user=ubuntu",
"ansible_ssh_common_args=-o 'StrictHostKeyChecking=no'",
"[all]",
"[etcd]",
"[first-kube-master]",
"[not-first-kube-master]",
"[kube-master]",
"[kube-node]",
"[k8s-cluster:children]",
"kube-master",
"kube-node"
]


master_node_names = list(json.loads(sys.argv[1]))
master_node_ids = list(json.loads(sys.argv[2]))
worker_node_names = list(json.loads(sys.argv[3]))
worker_node_ids = list(json.loads(sys.argv[4]))

with open("ansible_hosts.txt", "w") as f:
    f.writelines([line + "\n" for line in default_text])

with open("ansible_hosts.txt", "r+") as f:
    lines = f.readlines()
    f.seek(0)
    for i, line in enumerate(lines):
        f.write(line)
        if "[all]" in line:
            for j in range(0,len(master_node_names)):
                lines.insert(i + 1, master_node_names[j] + " ansible_host=" + master_node_ids[j] + "\n")
            for j  in range(0,len(worker_node_names)):
                lines.insert(i + 1, worker_node_names[j] + " ansible_host=" + worker_node_ids[j] + "\n")
    f.seek(0)
    f.truncate()
    f.writelines(lines)

with open("ansible_hosts.txt", "r+") as f:
    lines = f.readlines()
    f.seek(0)
    for i, line in enumerate(lines):
        f.write(line)
        if "[first-kube-master]" in line:
            lines.insert(i + 1, master_node_names[0] + "\n")
        if "[not-first-kube-master]" in line:
            for j in range(1,len(master_node_names)):
                lines.insert(i + 1, master_node_names[j] + "\n")
        if "[kube-master]" in line:
            for j in range(0,len(master_node_names)):
                lines.insert(i + 1, master_node_names[j] + "\n")
        if "[etcd]" in line:
            for j in range(0,len(master_node_names)):
                lines.insert(i + 1, master_node_names[j] + "\n")
    f.seek(0)
    f.truncate()
    f.writelines(lines)

with open("ansible_hosts.txt", "r+") as f:
    lines = f.readlines()
    f.seek(0)
    for i, line in enumerate(lines):
        f.write(line)
        if "[kube-node]" in line:
            for j in range(0,len(worker_node_names)):
                lines.insert(i + 1, worker_node_names[j] + "\n")
    f.seek(0)
    f.truncate()
    f.writelines(lines)
