iniciar terraform:
terraform init

arrancar infra:
terraform apply

obtener suscription id:
az account show --query id -o tsv 

obtener tenant id:
az account show --query tenantId -o tsv 

Obtener client id:
az ad sp list --display-name sp-jgarcia-dvfinlab-01 

conexión:
ssh azureuser@ip

editor 1:
sudo nano /etc/postgresql/12/main/postgresql.conf

poner:

listen_addresses = '*'

editor 2:
sudo nano /etc/postgresql/12/main/pg_hba.conf

bajar hasta abajo del todo y poner:

host    all    all    0.0.0.0/0    md5

realizamos restart del postgres

sudo systemctl restart postgresql

y ya deberiamos poder conectarnos

INSTALAR ANSIBLE

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

USAR ANSIBLE

ansible-playbook -i inventory/dev.ini playbooks/install_postgresql.yml
ansible-playbook -i inventory/dev.ini playbooks/backup_postgresql.yml

DESINSTALAR TODO POSGRE

sudo systemctl stop postgresql
sudo apt-get --purge remove postgresql\* -y
sudo apt-get autoremove -y
sudo rm -rf /etc/postgresql /var/lib/postgresql /var/log/postgresql /etc/postgresql-common /usr/lib/postgresql

INSTALAR PROGRE EN LA VM PUBLICA

sudo apt update
sudo apt install -y postgresql-client
PGPASSWORD=password psql -h 10.0.1.5 -U root -d proyecto_final -c '\l'

INSTALAR AZ

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash












