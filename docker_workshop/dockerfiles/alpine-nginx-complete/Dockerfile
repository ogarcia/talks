FROM alpine:3.14.2

RUN apk -U upgrade && apk add nginx && echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx-default.conf /etc/nginx/http.d/default.conf

VOLUME ["/srv/http"]

CMD /usr/sbin/nginx
