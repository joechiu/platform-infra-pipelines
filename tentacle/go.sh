
cd tf
terraform init
terraform apply -auto-approve

cd ../ansible
ansible-playbook -i hosts playbook.yml
