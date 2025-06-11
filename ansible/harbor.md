USUARIO Y CONTRASEÑA

admin
Harbor@12345

USUARIO Y CONTRASEÑA JAVIER

jga
ga12345678!

probar harbor

curl -k -u admin:Harbor@12345 -X POST "https://core.proyectojga/api/v2.0/users" \
  -H "Content-Type: application/json" \
  -d '{"username": "jga", "email": "jga@fake.com", "password": "Jga12345678!", "realname": "JGA"}'

curl -k -u admin:Harbor@12345 -X POST "https://core.proyectojga/api/v2.0/projects/library/members" \
  -H "Content-Type: application/json" \
  -d '{
    "role_id": 1,
    "member_user": {
      "username": "jga"
    }
  }'

