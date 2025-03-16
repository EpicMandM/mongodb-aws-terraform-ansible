# NEBO Project

This project automates the deployment and configuration of a MongoDB database using Terraform for infrastructure provisioning and Ansible for configuration management.

## Prerequisites

- Terraform >= 1.9.0
- Ansible
- AWS CLI configured with appropriate permissions
- SSH key pair (default: `~/.ssh/id_ed25519`)
- Python 3.9

## Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd NEBO
   ```

2. **Create Terraform variables file:**
   Create a `terraform.tfvars` file with your SSH public key:
   ```
   ssh_public_key = "your-ssh-public-key-content"
   ```
   Or create TF_VAR:
   ```
   export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_ed25519.pub) 
   ```

3. **Set up Ansible Vault:**
   The project uses Ansible Vault to securely store sensitive information.
   ```bash
   chmod +x get_vault_pass.sh
   ```

4. **Initialize Terraform:**
   ```bash
   terraform init
   ```

## Deploy Infrastructure

1. **Plan the deployment:**
   ```bash
   terraform plan
   ```

2. **Apply the configuration:**
   ```bash
   terraform apply
   ```

This will:
- Create AWS infrastructure (VPC, subnet, security group, EC2 instance)
- Install and configure MongoDB on the provisioned instance
- Set up MongoDB users and collections

## Project Structure

```
NEBO/
├── .ansible/              # Ansible workspace directory
│   ├── collections/       # Ansible collections
│   ├── modules/           # Ansible modules
│   ├── roles/             # Ansible roles
│   │   └── db/            # MongoDB database role
│   │       ├── files/     # Configuration files
│   │       │   └── mongod.conf    # MongoDB configuration
│   │       ├── tasks/     # Role tasks
│   │       │   ├── configure.ansible.yml  # DB configuration
│   │       │   ├── main.yml              # Main tasks file
│   │       │   └── provision.ansible.yml  # DB provisioning
│   │       └── vars/      # Variables
│   │           └── vault.yml  # Encrypted secrets
│   └── .lock              # Ansible lock file
├── terraform/             # Terraform configuration
│   ├── scripts/           # Scripts directory
│   │   └── get_vault_pass.sh  # Vault password script
│   ├── main.tf            # Terraform main configuration
│   ├── outputs.tf         # Terraform outputs
│   └── variables.tf       # Terraform variables
├── .vscode/               # VSCode configuration
│   └── settings.json      # Editor settings
├── .ansible-lint          # Ansible linting configuration
├── .gitignore             # Git ignore file
├── ansible.cfg            # Ansible configuration
├── playbook.yml           # Main Ansible playbook
└── README.md              # This file
```

## Security

- Sensitive information is stored in Ansible Vault
- The vault password is derived from your SSH private key
- MongoDB is configured with authentication enabled
- AWS security group restricts access to necessary ports

## Customization

To customize the MongoDB configuration:
1. Edit `.ansible/roles/db/files/mongod.conf`
2. Update variables in the vault file:
   ```bash
   ansible-vault edit --vault-password-file=terraform/scripts/get_vault_pass.sh .ansible/roles/db/vars/vault.yml
   ```

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Note

This project is designed for experimental purposes. For production use, consider additional security measures and backup strategies.
