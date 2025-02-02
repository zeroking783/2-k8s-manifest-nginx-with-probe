{{- define "nginx2-config" -}}
events {}
http {
    error_log /var/log/nginx/error.log warn;
    access_log /var/log/nginx/access.log;

    log_format healthz_log  '$remote_addr - $remote_user [$time_local] "$request" '
                            '$status $body_bytes_sent "$http_referer" '
                            '"$http_user_agent"';
    access_log /var/log/nginx/healthz.log healthz_log;

    log_format proxy_log    '$remote_addr - $remote_user [$time_local] "$request" '
                            '$status $body_bytes_sent "$http_referer" '
                            '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/proxy.log proxy_log;

    server {
        listen 80;  

        location /healthz {
            add_header Content-Type text/plain;
            return 200 'The service is alive';
            access_log /var/log/nginx/healthz.log healthz_log;
        }  

        location /proxy {
            add_header Conetnt-Type text/plain;
            return 200 'Test proxy response received. Your request has been logged.';
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