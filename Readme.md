
# Self-Managed DevOps Platform with Terraform, Ansible, and Kubeadm

## Pre-requisites

- Terraform installed  
- Ansible installed  
- AWS CLI configured  

---

### Step 1: Configure the Remote Backend (State File)

```bash
cd ./backend-setup
```
```bash
terraform init
```
```bash
terraform plan
```
```bash
terraform apply
```

After the command completes, the bucket name will be displayed in the console output.

Update the **backend.tf** file in the **terraform-infra** directory with this bucket name.


---

### Step 2: Provision AWS Infrastructure and DevOps Tools (Kubernetes, Jenkins, Nexus) Using Terraform

```bash
cd ../terraform-infra
```

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

After the provisioning process completes, the IP addresses of the Kubernetes master and worker nodes, as well as optional tools such as Jenkins, Nexus, and database servers, will be displayed in the output.

---

### Step 3: SSH into your Bastion host and clone this repo
3b. Make sure your key has proper permissions
3c. Ping all hosts to ensure your Bastion host can communicate with other hosts in your private network. (Optional)

```bash 
ansible -i inventory/hosts.ini -m ping
```

### Step 4: Update hosts.ini File

```bash
cd ../k8s-ansible
```

Copy these IP addresses and update the **inventory/hosts.ini** file located in the k8s-ansible directory with the correct IPs and login credentials.

---

### Step 5: Prepare Nodes

Apply the following command to install all required dependencies on all nodes:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/all.yml
```

---

### Step 6: Initialize the Cluster and Join Worker Nodes

Run the following playbook to initialize the Kubernetes cluster and join the worker nodes:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/cluster.yml
```

---

### Step 7: Configure Additional Tools (Optional)

```bash
ansible-playbook -i inventory/hosts.ini playbooks/db.yml

ansible-playbook -i inventory/hosts.ini playbooks/nexus.yml

ansible-playbook -i inventory/hosts.ini playbooks/proxy.yml

ansible-playbook -i inventory/hosts.ini playbooks/nexus_repo_config.yml
```

### Setup Jenkins Server 
```bash
ansible-playbook -i inventory/hosts.ini playbooks/jenkins.yml
```
### Install plugins in Jenkins 

### Run this to encrypt the vaults
```bash
cd k8s-ansible
ansible-vault encrypt group_vars/jenkins/vault.yml
```

### NOTE: Make sure to login with Jenkins Initial password and create username and Password for authentication before running this command otherwise you will get Error **"HTTP Error 401: Unauthorized"**.

```bash
ansible-playbook -i inventory/hosts.ini playbooks/jenkins_plugins_cred.yml --ask-vault-pass
```
### NOTE: After setting up the proxy server for ssl termination, Configure Docker Daemon in jenkins server or agent to trust the certificate.

```bash
ansible-playbook -i inventory/hosts.ini playbooks/trust_cert_jenkins.yml 
```
