# Alpine con NGINX

Para construir.
```
docker build -t gpulnginxcomplete:1 .
```

Para ejecutar.
```
docker run -d --rm -p 8080:80 --name gpulnginx gpulnginxcomplete:1
```

Al tener la orden `VOLUME` en el _Dockerfile_ crea un volumen para el
alojamiento de nginx `/srv/http`.

Podemos nosotros crearlo antes.
```
docker volume create gpulnginx
docker volume inspect gpulnginx
```

Y usarlo.
```
docker run -d --rm -p 8080:80 -v gpulnginx:/srv/http --name gpulnginx gpulnginxcomplete:1
docker exec -t -i gpulnginx sh
echo "Hola GPUL" > /srv/http/index.html
```
