# virtual network 

# This creates the main virtual network for your AKS cluster. It's the foundation of your networking infrastructure. It:
# - Defines the address space (range of IP addresses) for your entire cluster
# - Provides network isolation in Azure
# - Acts as the parent for all subnets you'll create
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.fullname}-${var.env}-virtual-network"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# aks subnets

# Creates a dedicated subnet within the virtual network specifically for AKS nodes. It:
# - Allocates a portion of the virtual network's address space for AKS
# - Defines where the actual Kubernetes worker nodes will be deployed
# - Must have enough IP addresses for all your nodes and services
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.fullname}-${var.env}-aks-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.aks_subnet_address_prefix
  depends_on           = [azurerm_virtual_network.virtual_network]
}

# NSG for aks subnet

# Creates a network security group (firewall) for the AKS subnet. It:
# - Acts as a stateful firewall for your subnet
# - Controls which traffic is allowed in and out
# - Protects your cluster from unauthorized access
# - References the aks-nsg name to organize all security rules
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags
}

# NSG rules for aks subnet

# Creates inbound NSG rules based on the CSV file data. These rules:
# - Define what traffic can enter your AKS subnet
# - Specify allowed protocols (TCP/UDP), ports, and source IPs
# - Use priorities to determine rule evaluation order (lower number = higher priority)
# - Examples: allowing SSH, API server traffic, application ports, etc.
resource "azurerm_network_security_rule" "aks_nsg_inbound" {
  for_each                    = var.aks_nsg_inbound_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.rule_type
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix_cidr
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  depends_on                  = [azurerm_network_security_group.aks_nsg]
}

#  outbound NSG rules.

# Creates outbound NSG rules based on the CSV file data. These rules:
# - Define what traffic can leave your AKS subnet
# - Allow your nodes to communicate with external services (registries, APIs, etc.)
# - Typically more permissive than inbound rules for flexibility
resource "azurerm_network_security_rule" "aks_nsg_outbound" {
  for_each                    = var.aks_nsg_outbound_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.rule_type
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix_cidr
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  depends_on                  = [azurerm_network_security_group.aks_nsg]
}

# Associating the NSG with the subnet

# This resource links the "aks-nsg" NSG to the AKS subnet. It:
# - Applies all the defined NSG rules to the subnet
# - Ensures that the security rules are enforced for all traffic to/from the subnet
# - Without this, the NSG rules wouldn't apply to your cluster
resource "azurerm_subnet_network_security_group_association" "nsg_associate_aks_subnet" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
  depends_on                = [azurerm_network_security_group.aks_nsg, azurerm_subnet.aks_subnet]
}


# In summary: These resources create a complete, secure network foundation where your AKS cluster's
# nodes will run, with controlled access through security rules defined in your CSV file.
