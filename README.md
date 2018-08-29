# kubernetes-init

Here is the instruction on how to setup kubernetes cluster using kubeadm via proxy.

# For kube-master:

## Setup Proxy
export https_proxy="<your_proxy_server>"
export http_proxy="<your_proxy_server"
## Excluding Proxy for KUBE API Server
export no_proxy="<all_of_your_kube_nodes_and_masters>"
## Execute Script
sh init_master.sh

# For kube-node:

## Setup Proxy
export https_proxy="<your_proxy_server>"
export http_proxy="<your_proxy_server"
## Excluding Proxy for KUBE API Server
export no_proxy="<all_of_your_kube_nodes_and_masters>"
## Execute Script
sh init_node.sh
