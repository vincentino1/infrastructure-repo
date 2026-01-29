### Using This Ansible Project (Jenkins Plugin Automation)

This project installs and manages Jenkins plugins using Ansible.
Some configuration values (like Jenkins admin credentials) are stored securely using Ansible Vault.

----
### Before You Begin
Before running the playbook, you must update these things:
1. Update jenkins_instance (jenkins_url) in vars
2. Update your Ansible inventory file
Make sure your inventory points to the correct host where Jenkins is installed.
3. Login to Jenkins with the first Jenkins password then create your jenkins_admin_user and jenkins_admin_password and replace them in  vars/main.yml

## how to run the configuration 
```bash
ansible-playbook -i inventories/hosts.ini playbooks/jenkins.yml --ask-vault-pass
```


### Troubleshooting
**Error:**
*Credentials dropdown does not show newly created credentials in Jenkins*
**Solution:** If you want to use an API Token do not create a new credentials with a secret text but with username/password and use the token as your password!and username as github username.

More information here: https://stackoverflow.com/questions/48330402/secret-text-git-credentials-not-showing-up-in-jenkins-project-source-code-mana




