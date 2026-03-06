# Azure AKS infrastructure-as-Code Project

## 📋 Project Overview

This repository contains a **production-ready Terraform infrastructure-as-code (IaC)** project for deploying and managing **Azure Kubernetes Service (AKS)** clusters on Microsoft Azure. The project automates the complete provisioning of a highly available, scalable, and secure Kubernetes infrastructure with optimal networking, container registry, and security configurations.

### Core Components

- **Azure Kubernetes Service (AKS)**: A managed Kubernetes container orchestration platform
- **Azure Container Registry (ACR)**: A private container registry for storing and managing Docker images
- **Azure Virtual Network (VNet)**: Network isolation and segmentation for the AKS cluster
- **Network Security Groups (NSG)**: Inbound and outbound traffic control and filtering
- **GitHub Actions CI/CD**: Automated infrastructure provisioning and destruction workflows

---

## 🎯 Project Goals

1. **Infrastructure Automation**: Eliminate manual Azure resource provisioning using Terraform
2. **Multi-environment Support**: Support multiple deployment environments (dev, staging, production) using Terraform workspaces
3. **Security First**: Implement network security, private container registries, and Azure AD authentication
4. **High Availability**: Deploy nodes across multiple availability zones and implement auto-scaling
5. **Cost Optimization**: Use right-sized VMs and auto-scaling to manage cloud costs effectively
6. **CI/CD Integration**: Automated infrastructure deployment via GitHub Actions workflows
7. **Scalability**: Auto-scaling node pools for handling varying workload demands

---

## 🏗️ Architecture

### Infrastructure Design

```
┌─────────────────────────────────────────────────────────────┐
│           Azure Resource Group (RG)                         │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Virtual Network (VNet)                              │   │
│  │  Address Space: 10.10.0.0/16                         │   │
│  │                                                       │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │  AKS Subnet            (10.10.0.0/21)         │  │   │
│  │  │  ┌──────────────────────────────────────────┐  │  │   │
│  │  │  │  AKS Cluster                             │  │  │   │
│  │  │  │  ┌──────────────┐  ┌──────────────────┐  │  │  │   │
│  │  │  │  │ Master Nodes │  │  Worker Nodes    │  │  │  │   │
│  │  │  │  │ (System)     │  │  (User Workload) │  │  │  │   │
│  │  │  │  └──────────────┘  └──────────────────┘  │  │  │   │
│  │  │  └──────────────────────────────────────────┘  │  │   │
│  │  │                                                 │  │   │
│  │  │  Network Security Group (NSG)                  │  │   │
│  │  │  - Inbound: HTTP (80), HTTPS (443)            │  │   │
│  │  │  - Outbound: Internet access                  │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Azure Container Registry (ACR)                      │   │
│  │  - Premium SKU for private image storage             │   │
│  │  - Azure AD authentication support                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

1. **Network Architecture**: Uses a dedicated VNet with a /21 subnet to support the AKS cluster with ample IP addresses for pods and services
2. **Node Pool Strategy**: Separate system and user node pools for optimal resource utilization and workload isolation
3. **Auto-scaling**: Both master and worker node pools are configured with auto-scaling for dynamic workload handling
4. **Network Security**: NSG rules restrict inbound traffic to HTTP/HTTPS and allow controlled outbound internet access
5. **Container Registry**: Premium ACR SKU enables private image storage and Azure AD authentication for enhanced security

---

## 📁 Project Structure

```
azure-aks-project/
├── README.md                          # Project documentation
├── main.tf                            # Main Terraform configuration (RG, ACR, modules)
├── variables.tf                       # Input variable definitions
├── locals.tf                          # Local variable definitions (NSG rules from CSV)
├── backend.tf                         # Azure backend configuration for state management
├── provider.tf                        # Azure provider configuration
├── terraform.tfvars                   # Variable values for deployment
├── nsg_rules.csv                      # Network Security Group rules in CSV format
├── .gitignore                         # Git ignore patterns
├── .terraform.lock.hcl               # Terraform provider lock file
├── .terraform/                        # Local Terraform state and provider cache
│   ├── environment                    # Terraform backend environment config
│   ├── terraform.tfstate              # Local state file
│   └── providers/                     # Cached provider binaries
├── terraform.tfstate.d/               # Remote state files per environment
│   └── dev/                           # Development environment state
└── modules/
    ├── aks/
    │   ├── main.tf                    # AKS cluster resource configuration
    │   ├── variables.tf               # AKS module input variables
    │   └── outputs.tf                 # AKS module output values
    └── network/
        ├── main.tf                    # VNet, subnet, and NSG configuration
        ├── variables.tf               # Network module input variables
        └── outputs.tf                 # Network module output values

.github/
└── workflows/
    ├── provision-infra.yml            # GitHub Action to provision infrastructure
    └── destroy-infra.yml              # GitHub Action to destroy infrastructure
```

### File Descriptions

| File | Purpose |
|------|---------|
| `main.tf` | Root module defining Azure Resource Group, Container Registry, and module composition |
| `variables.tf` | Input variables for location, cluster config, node pools, scaling parameters |
| `locals.tf` | Local variables, NSG rule parsing from CSV file, environment/workspace mapping |
| `backend.tf` | Azure Storage backend for remote Terraform state management |
| `provider.tf` | Azure provider version constraint and authentication configuration |
| `terraform.tfvars` | Variable values for West Europe deployment with specific VM sizes and scaling settings |
| `nsg_rules.csv` | Centralized network security rules (HTTP, HTTPS, outbound internet) |

---

### Network Security Rules (nsg_rules.csv)

```csv
sg_name    rule_name              rule_type  protocol  priority  access  source/destination
aks-nsg    AllowHTTP              Inbound    Tcp       100       Allow   0.0.0.0/0 → *:80
aks-nsg    AllowHTTPS             Inbound    Tcp       110       Allow   0.0.0.0/0 → *:443
aks-nsg    AllowInternetOutbound  Outbound   *         100       Allow   * → Internet
```

---

## 📦 Modules Overview

### Network Module (`modules/network/`)

Creates and configures the networking foundation for AKS:

**Resources:**
- **Azure Virtual Network (VNet)**: Core network with configurable address space
- **AKS Subnet**: Dedicated subnet for Kubernetes nodes and pod networking
- **Network Security Group (NSG)**: Security rules for inbound/outbound traffic
- **NSG Association**: Links NSG to AKS subnet for traffic filtering

**Key Features:**
- Centralized network management
- Flexible subnet sizing for pod density
- Rule-based traffic control imported from CSV

### AKS Module (`modules/aks/`)

Manages the Kubernetes cluster configuration and node pools:

**Resources:**
- **Azure Kubernetes Service Cluster**: Managed Kubernetes control plane
- **Default/Master Node Pool**: System component pods (system-mode)
- **Worker Node Pool**: User workload pods (user-mode)
- **ACR Integration**: Pod access to private images via managed identity

**Key Features:**
- Multi-zone deployment for high availability
- Auto-scaling for cost optimization
- Premium ACR integration for secure image pulling
- Configurable Kubernetes version
- Private cluster option for enhanced security

---

## 🚀 Getting Started

### Prerequisites

1. **Azure Account**
   - Active Azure subscription
   - Appropriate permissions (Contributor role minimum)

2. **Local Tools**
   - [Terraform](https://www.hashicorp.com/products/terraform) >= 1.14.0
   - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) for manual operations
   - [kubectl](https://kubernetes.io/docs/tasks/tools/) for cluster interaction

3. **Terraform State Backend**
   - Azure Storage Account for remote state
   - Details configured in GitHub Actions secrets (see CI/CD section)

### Local Setup Instructions

#### 1. Clone and Navigate to Project

```bash
cd azure-aks-project
```

#### 2. Authenticate with Azure

```bash
# Interactive login
az login

# Or set environment variables for automation
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

#### 3. Initialize Terraform

```bash
# Initialize Terraform (downloads providers and modules)
terraform init

# For state stored in Azure Storage:
terraform init \
  -backend-config="resource_group_name=YOUR_RG" \
  -backend-config="storage_account_name=YOUR_STORAGE" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=azure-aks/terraform.tfstate"
```

#### 4. Review Configuration

```bash
# Validate Terraform syntax
terraform validate

# Format code to standards
terraform fmt -recursive
```

#### 5. Plan and Apply

```bash
# Create/select workspace (dev, staging, prod)
terraform workspace new dev || terraform workspace select dev

# Preview changes
terraform plan -out=tfplan

# Apply infrastructure (requires confirmation)
terraform apply tfplan
```

---

## 🔄 CI/CD Deployment via GitHub Actions

### Workflows Overview

#### Provision Infrastructure (`provision-infra.yml`)

**Trigger:** Manual workflow dispatch with workspace selection

**Steps:**
1. Checkout code from repository
2. Authenticate to Azure using OIDC (secure, no secrets in logs)
3. Setup Terraform
4. Initialize Terraform with remote backend configuration
5. Select/create Terraform workspace
6. Run `terraform plan` for review
7. Run `terraform apply` to deploy infrastructure
8. Optionally upload kubeconfig as artifact

**Required GitHub Secrets:**
```
AZURE_CLIENT_ID          # Service principal client ID
AZURE_TENANT_ID          # Azure tenant ID
AZURE_SUBSCRIPTION_ID    # Azure subscription ID
TF_BACKEND_RG            # Resource group containing state storage
TF_BACKEND_STORAGE_ACCOUNT # Storage account for Terraform state
TF_BACKEND_CONTAINER     # Container name in storage account
TF_BACKEND_KEY           # State file path (e.g., "azure-aks/terraform.tfstate")
```

#### Destroy Infrastructure (`destroy-infra.yml`)

**Trigger:** Manual workflow dispatch with workspace selection

**Purpose:** Clean up resources to avoid unnecessary Azure charges

**Steps:**
1. Similar setup as provision workflow
2. Run `terraform destroy` to remove all resources
3. Requires confirmation

### GitHub Actions Setup

1. **Create Azure OIDC Service Principal:**
   ```bash
   az ad sp create-for-rbac \
     --name "github-actions-aks" \
     --role Contributor \
     --scopes /subscriptions/YOUR_SUBSCRIPTION_ID
   ```

2. **Configure GitHub Secrets:**
   - Go to repository Settings → Secrets and variables → Actions
   - Add all required secrets from the list above

3. **Trigger Workflow:**
   - Navigate to Actions tab
   - Select "Provision Infrastructure"
   - Click "Run workflow"
   - Select workspace (dev, staging, production)
   - Confirm and monitor execution

---

## 🔐 Security Features

### Access Control

- **Azure AD Integration**: Pod identities authenticate to ACR without storing credentials
- **Private Cluster Option**: API server not exposed to public internet (configurable)
- **Network Isolation**: NSG rules restrict traffic to necessary ports only
- **Pod Security**: Network policies can be implemented post-deployment

### Data Protection

- **State File Encryption**: Remote state stored in Azure Storage with encryption at rest
- **Private Container Registry**: ACR Premium SKU with authentication requirements
- **Network Segmentation**: Dedicated subnet prevents unauthorized access

### Compliance

- **Tagging**: All resources tagged for cost allocation and compliance tracking
- **Resource Naming**: Consistent naming convention with environment prefix
- **Audit Logging**: Azure activity logs track infrastructure changes

---

## 📊 Scaling and Performance

### Auto-scaling Configuration

**Master Nodes (System):**
- Minimum: 1 node (cost optimization)
- Maximum: 3 nodes (high availability during peak load)
- Auto-scaling enabled for dynamic adjustment

**Worker Nodes (User Workload):**
- Minimum: 1 node (cost optimization)
- Maximum: 3 nodes (application scaling limits)
- Desired: 2 nodes (baseline capacity)
- Auto-scaling enabled for workload demands

### Performance Tuning

**VM Size Selection:**
- **Master**: `Standard_B8s_v2` (8 vCPUs, 64 GB ram) - suitable for system components
- **Worker**: `Standard_A8_v2` (8 vCPUs, 16 GB RAM) - balanced for user applications

**Pod Density:**
- Maximum 110 pods per node (configurable in `worker_max_pods`)
- Allows efficient resource utilization

**Availability Zones:**
- Master nodes: Zone 2 (single AZ for cost optimization)
- Worker nodes: Zone 1 (single AZ)
- Can be expanded to multiple zones for geo-redundancy

---

## 🛠️ Terraform State Management

### State Storage

- **Type**: Azure Blob Storage (remote backend)
- **Encryption**: At rest via Azure Storage encryption
- **Locking**: Prevents concurrent modifications
- **Location**: Configured in `.github/workflows/` secrets and `backend.tf`

### Workspace Strategy

Terraform workspaces enable multi-environment management:

```bash
# List workspaces
terraform workspace list

# Create and switch
terraform workspace new staging
terraform workspace select prod

# Each workspace maintains separate state file
# Stored in: terraform.tfstate.d/{workspace}/terraform.tfstate
```

### State Inspection

```bash
# View state file content
terraform show

# List specific resources
terraform state list

# Show resource details
terraform state show azurerm_kubernetes_cluster.aks-cluster
```

---

## 📋 Common Operations

### Update Kubernetes Version

```hcl
# In terraform.tfvars
cluster_version = "1.34.0"
```

Add, commit, and run `terraform apply`.

### Scale Node Pools

```hcl
# Adjust auto-scaling limits
worker_max_count = 5
worker_min_count = 2
```

### Add Network Rules

1. Edit `nsg_rules.csv`:
   ```csv
   aks-nsg,AllowCustomApp,Inbound,Tcp,120,Allow,*,8080,*,*
   ```

2. Reapply Terraform:
   ```bash
   terraform plan && terraform apply
   ```


---

## 📝 License

This project is provided as-is for infrastructure deployment and management.

---

## 👤 Author

**Project Owner**: ahmedoun  
**Created**: 2026 
**Last Updated**: 2026

For questions or issues, refer to the project documentation or Azure support channels.

---

## Changelog

### Version 1.0.0
- Initial infrastructure setup with AKS, VNet, and NSG configuration
- Support for dev environment deployment
- GitHub Actions workflows for infrastructure provisioning
- Premium ACR integration
- Multi-zone node pool support with auto-scaling
