

Pre-requisites
. terraform installed 
. ansible installed 
. aws cli configured


### Step 1: Configure the Remote Backend (State File)

cd ./backend-setup

terraform init

then 

terraform plan

then 

terraform apply

After the command completes, the bucket name will be displayed in the console output.  Update the `backend.tf` file in the `terraform-infra` directory with this bucket name.

### Step 2: Provision AWS Infrastructure and DevOps Tools (Kubernetes, Jenkins, Nexus) Using Terraform

cd ../terraform-infra

terraform init

then 

terraform plan

then 

terraform apply

After the provisioning process completes, the IP addresses of the Kubernetes master, worker nodes, Jenkins, Nexus, and database servers will be displayed in the output.  
Copy these IP addresses and update the `inventories/hosts.ini` file located in the `k8s-ansible` directory.

### Step 3: Update host.ini file 

cd ../k8s-ansible

Make sure to update the `inventories/hosts.ini` file in the `k8s-ansible` directory with the correct IP addresses **and** their login credentials.


### Step 4: Prepare Nodes

Apply the following command to install all required dependencies on all nodes:


ansible-playbook -i inventories/hosts.ini playbooks/all.yml

### Step 5: Initialize the cluster and Join worker nodes

ansible-playbook -i inventories/hosts.ini playbooks/cluster.yml

### Step 6: Configure Additional Tools (optional)

You can configure other tools such as Jenkins, Nexus, and the database if you plan to use them in your environment.  
Follow their respective playbooks or setup instructions to complete the configuration.

ansible-playbook -i inventories/hosts.ini playbooks/db.yml

ansible-playbook -i inventories/hosts.ini playbooks/jenkins.yml

ansible-playbook -i inventories/hosts.ini playbooks/nexus.yml



# Self-Managed Devops platform with Terraform, Ansible, and Kubeadm

## Pre-requisites

- Terraform installed  
- Ansible installed  
- AWS CLI configured  

---

### Step 1: Configure the Remote Backend (State File)

```bash
cd ./backend-setup
terraform init
terraform plan
terraform apply

After the command completes, the bucket name will be displayed in the console output.

Update the **`backend.tf`** file in the **`terraform-infra`** directory with this bucket name.


Step 2: Provision AWS Infrastructure and DevOps Tools (Kubernetes, Jenkins, Nexus) Using Terraform

cd ../terraform-infra
terraform init
terraform plan
terraform apply

After the provisioning process completes, the **IP addresses** of the **Kubernetes master** and **worker nodes**, as well as **optional tools** such as **Jenkins**, **Nexus**, and the **database servers**, will be displayed in the output.


Step 3: Update hosts.ini File

cd ../k8s-ansible

Copy these IP addresses and update the **inventories/hosts.ini** file located in the **k8s-ansible** directory.

Step 4: Prepare Nodes

Apply the following command to install all required dependencies on all nodes:

ansible-playbook -i inventories/hosts.ini playbooks/all.yml

This playbook will install necessary packages for Kubernetes and other DevOps tool installations.

Step 5: Initialize the Cluster and Join Worker Nodes

Run the following playbook to initialize the Kubernetes cluster and join the worker nodes:

ansible-playbook -i inventories/hosts.ini playbooks/cluster.yml

Step 6: Configure Additional Tools (Optional)

You can configure other tools such as Jenkins, Nexus, and the database if you plan to use them:

ansible-playbook -i inventories/hosts.ini playbooks/db.yml
ansible-playbook -i inventories/hosts.ini playbooks/jenkins.yml
ansible-playbook -i inventories/hosts.ini playbooks/nexus.yml
