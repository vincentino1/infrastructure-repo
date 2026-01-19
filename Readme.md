
# Self-Managed DevOps Platform with Terraform, Ansible, and Kubeadm

## Pre-requisites

- Terraform installed  
- Ansible installed  
- AWS CLI configured  

---

### Step 1: Configure the Remote Backend (State File)

cd ./backend-setup

# Initialize Terraform backend
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

After the command completes, the bucket name will be displayed in the console output.

Update the **backend.tf** file in the **terraform-infra** directory with this bucket name.

---

### Step 2: Provision AWS Infrastructure and DevOps Tools (Kubernetes, Jenkins, Nexus) Using Terraform

cd ../terraform-infra

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

After the provisioning process completes, the IP addresses of the Kubernetes master and worker nodes, as well as optional tools such as Jenkins, Nexus, and database servers, will be displayed in the output.

---

### Step 3: Update hosts.ini File

cd ../k8s-ansible

Copy these IP addresses and update the **inventories/hosts.ini** file located in the k8s-ansible directory with the correct IPs and login credentials.

---

### Step 4: Prepare Nodes

Apply the following command to install all required dependencies on all nodes:

ansible-playbook -i inventories/hosts.ini playbooks/all.yml

---

### Step 5: Initialize the Cluster and Join Worker Nodes

Run the following playbook to initialize the Kubernetes cluster and join the worker nodes:

ansible-playbook -i inventories/hosts.ini playbooks/cluster.yml

---

### Step 6: Configure Additional Tools (Optional)

ansible-playbook -i inventories/hosts.ini playbooks/db.yml
ansible-playbook -i inventories/hosts.ini playbooks/jenkins.yml
ansible-playbook -i inventories/hosts.ini playbooks/nexus.yml
