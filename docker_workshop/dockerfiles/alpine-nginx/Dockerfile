FROM alpine:3.14.2

RUN apk -U upgrade
RUN apk add nginx && echo "daemon off;" >> /etc/nginx/nginx.conf

CMD /usr/sbin/nginx
