comandos útiles para docker

EN EL REPO DE FRONTEND
docker build -t jga-frontend .
EN EL REPO DE BACKEND
docker build -t jga-backend .

Una vez construida (si tenemos el acr montado)

docker tag jga-frontend acrjgarcia123.azurecr.io/jga-frontend:1

docker tag jga-backend acrjgarcia123.azurecr.io/jga-backend:1

subir la imagen

az acr login --name acrjgarcia123
docker push acrjgarcia123.azurecr.io/jga-backend:1
docker push acrjgarcia123.azurecr.io/jga-frontend:1

