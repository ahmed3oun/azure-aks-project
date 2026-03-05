resource "azurerm_resource_group" "rg" {
  name     = "${var.fullname}-rg-${terraform.workspace}"
  location = var.location
}


resource "azurerm_container_registry" "acr" {                                        # ACR for AKS cluster
  name                = "${replace(var.fullname, "-", "")}acr${terraform.workspace}" # ACR name must be globally unique and can only contain lowercase letters and numbers
  resource_group_name = azurerm_resource_group.rg.name                               # ACR (azure container registry)must be in the same region as AKS cluster
  location            = var.location
  # sku                 = "Standard" # Standard SKU is sufficient for AKS cluster, Premium SKU is not necessary and more expensive
  sku        = "Premium" # Premium SKU is required for AKS cluster to use the ACR as a private registry with Azure AD authentication
  depends_on = [azurerm_resource_group.rg]
}

module "network" { # Network module to create VNet and Subnet for AKS cluster
  source = "./modules/network"

  env                       = local.env
  rg_name                   = azurerm_resource_group.rg.name
  location                  = var.location
  fullname                  = var.fullname
  tags                      = var.tags
  vnet_address_space        = var.vnet_address_space
  aks_subnet_address_prefix = var.aks_subnet_address_prefix
  aks_nsg_inbound_rules     = local.aks_nsg_inbound_rules
  aks_nsg_outbound_rules    = local.aks_nsg_outbound_rules
}

module "aks" { # AKS cluster module to create AKS cluster with the specified configuration and parameters
  source = "./modules/aks"

  env                     = local.env
  location                = var.location
  acr_id                  = azurerm_container_registry.acr.id # Pass the ACR ID to the AKS module to allow it to pull images from the ACR
  fullname                = var.fullname
  cluster_version         = var.cluster_version
  tags                    = var.tags # Pass the tags variable to the AKS module to apply the same tags to the AKS cluster and its resources
  resource_group_name     = azurerm_resource_group.rg.name # Pass the resource group name to the AKS module to create the AKS cluster in the same resource group as the ACR and VNet
  vnet_subnet_id          = module.network.aks_subnet_id # Pass the subnet ID from the network module to the AKS module to associate the AKS cluster with the correct subnet
  private_cluster_enabled = var.private_cluster_enabled # Pass the private cluster enabled variable to the AKS module to determine whether to create a private AKS cluster or not: 
  # in a private AKS cluster, the API server is only accessible within the virtual network, providing enhanced security
  #  by preventing public access to the Kubernetes API. This is particularly beneficial for production environments or when handling
  #  sensitive workloads, as it reduces the attack surface and ensures that all interactions with the cluster occur over secure, 
  # internal network connections.
  # Master node configuration
  master_max_count          = var.master_max_count # Maximum number of nodes in the master node pool, allowing for scaling based on workload demands and ensuring high availability during peak times.
  master_min_count          = var.master_min_count
  master_vm_size            = var.master_vm_size # VM size for the master node pool, which determines the compute resources allocated to each node and can impact performance and cost.
  master_availability_zones = var.master_availability_zones # Availability zones for the master node pool, providing redundancy and high availability by distributing nodes across multiple zones within the region.
  master_os_disk_size_gb    = var.master_os_disk_size_gb
  # Worker node configuration
  worker_node_name           = var.worker_node_name
  worker_vm_size             = var.worker_vm_size
  worker_mode                = var.worker_mode
  worker_availability_zones  = var.worker_availability_zones
  worker_labels              = var.worker_labels
  worker_enable_auto_scaling = var.worker_enable_auto_scaling
  worker_max_count           = var.worker_max_count
  worker_min_count           = var.worker_min_count
  worker_desired_count       = var.worker_desired_count
  worker_max_pods            = var.worker_max_pods
  worker_node_taints         = var.worker_node_taints
  dns_zone_name              = var.dns_zone_name
  dns_zone_rg_name           = var.dns_zone_rg_name
  depends_on                 = [module.network, azurerm_container_registry.acr]
}

# To list the available VM SKUs in the West Europe region, you can use the Azure CLI command provided below. This will help you determine which VM sizes are available for your AKS cluster deployment.
# az vm list-skus \
#   --location westeurope \
#   --resource-type virtualMachines \
#   --output table
