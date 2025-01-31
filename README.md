## nginx1.yml

При отправке запросов
```
curl http://<minicube-ip>:30001
curl http://<minicube-ip>:30002
```
пишет OK.

Если зайти 
```
kubectl exec -it <pod-id> -- sh
```
и остановить службу nginx
```
nginx -s stop
```
, то при отправлении запроса уже не пишет OK, то есть ломается.

Но поскольку прописаны readinessProbe и livenessProbe, то через 20 секунд опять привычная реакция в виде OK.

Все запросы от readinessProbe и livenessProbe сохраняются в отдельном лог файле '/var/log/nginx/healthz.log', чтобы не засорять обычные запросы.

При отправке запросов 
```
curl http://<minikube-ip>:30001/proxy
```
запросы перенаправляются на второй nginx и возвращается ответ `Test proxy response received. Your request has been logged.`. Также если зайти в первый nginx
```
kubectl exec -it <pod-ip> -- sh
```
и отправить запрос от туда
```
curl http://nginx1-service:80/proxy
```
, то ответ будет идентичный. Все прокси запросы сохраняются в '/var/log/nginx/proxy.log' на обоих серверах. 