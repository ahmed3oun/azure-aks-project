location = "westeurope"
fullname = "ahmedoun"
tags = {
  "project" : "azure-aks-project",
  "owner" : "ahmedoun"
}
vnet_address_space        = ["10.10.0.0/16"]
aks_subnet_address_prefix = ["10.10.0.0/21"]
cluster_version           = "1.33.3"
private_cluster_enabled   = false

# master nodes
master_max_count          = 3
master_min_count          = 1
master_vm_size            = "Standard_B8s_v2"
master_os_disk_size_gb    = 30
master_availability_zones = ["2"]

# worker nodes
worker_node_name           = "usernodepool"
worker_vm_size             = "Standard_A8_v2"
worker_mode                = "System"
worker_availability_zones  = ["1"]
worker_labels              = {}
worker_enable_auto_scaling = true
worker_max_count           = 3
worker_min_count           = 1
worker_desired_count       = 2
worker_max_pods            = 110
worker_node_taints         = []

# External DNS zone 
dns_zone_name    = "aks.karimarous.com"
dns_zone_rg_name = "azure-terraform"

#  Standard_E4s_v6 is a good choice for AKS cluster nodes, as it provides a good balance of CPU, memory, and cost. It is based on the latest generation of AMD EPYC processors, which offer high performance and energy efficiency. Additionally, the E4s_v6 series supports up to 4 vCPUs and 32 GB of memory per VM, which is suitable for most AKS workloads. However, you should always check the available VM SKUs in your region and choose the one that best fits your specific requirements and budget.
# aks_node_vm_size = "Standard_E4s_v6"
# Standart_B8s_v2 is a good choice for AKS cluster nodes, as it provides a good balance of CPU, memory,
#  and cost. It is based on the latest generation of AMD EPYC processors, which offer high performance 
# and energy efficiency. Additionally, the B8s_v2 series supports up to 8 vCPUs and 64 GB of memory per VM,
#  which is suitable for most AKS workloads. However, you should always check the available VM SKUs in 
# your region and choose the one that best fits your specific requirements and budget.
# aks_node_vm_size = "Standard_B8s_v2"
