{{- define "nginx1-config" -}}
events {}
http {
    error_log /var/log/nginx/error.log warn;
    access_log /var/log/nginx/access.log;

    log_format proxy_log    '$proxy_protocol_addr - $remote_user [$time_local] "$request" '
                            '$status $body_bytes_sent "$http_referer" '
                            '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/proxy.log proxy_log;

    log_format healthz_log  '$remote_addr - $remote_user [$time_local] "$request" '
                            '$status $body_bytes_sent "$http_referer" '
                            '"$http_user_agent"';
    access_log /var/log/nginx/healthz.log healthz_log;

    server {
        listen 80;  

        location /healthz {
            add_header Content-Type text/plain;
            return 200 'The service is alive';
            access_log /var/log/nginx/healthz.log healthz_log;
        }

        location /proxy {
            proxy_pass http://nginx2-service:80/proxy;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; 
            add_header Content-Type text/plain;
            access_log /var/log/nginx/proxy.log proxy_log;
        }

        location / {
            add_header Content-Type text/plain;
            return 200 'OK';
            access_log /var/log/nginx/access.log;
        }
    }
}
{{- end -}}