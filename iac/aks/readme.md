terraform init

terraform apply -auto-approve

az account set --subscription 86f76907-b9d5-46fa-a39d-aff8432a1868

az aks get-credentials --resource-group rg-jgarcia-dvfinlab-uk --name aksjgarciaygn2r2 --overwrite-existing

kubectl config get-contexts

tendriamos este:  aks-jga   aks-jga    clusterAdmin_rg-jgarcia-dvfinlab_aks-jga

Vamos a usar el chart proporcionado (RECORDAD SUBIR IMAGENES DE DOCKER ANTES CON LOS NOMBRES DEL README)

helm install rrhh-jga .\proyecto_helm\ --namespace jga --create-namespace









