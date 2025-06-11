BORRAR TODO MENOS RG

terraform destroy "-target=module.vm" "-target=module.aks" "-target=module.peering" -auto-approve

OBTENER SSH + PODER CONECTARSE

terraform output -raw vm_private_key | Out-File -FilePath "$env:USERPROFILE\.ssh\id_rsa" -Encoding ascii

icacls "$env:USERPROFILE\.ssh\id_rsa" /inheritance:r
icacls "$env:USERPROFILE\.ssh\id_rsa" /grant:r "$($env:USERNAME):(R)"
icacls "$env:USERPROFILE\.ssh\id_rsa" /remove "Users"

terraform output -raw vm_public_ip

ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa azureuser@ip