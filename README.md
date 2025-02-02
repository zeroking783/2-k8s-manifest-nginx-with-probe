## Just Manifest and 'kubectl apply -f ...'

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


## HelmCharts

Захотел реализовать через HelmCharts, потому что они больше подходят для продуктовой разработки. 

В этом задании используются 2 одинаковых манифеста, отличаются пара переменных, а это как раз идеальный случай для HelmCharts как я понялл. 

Тут все максимально просто, одна команда меняется на другую:
```
helm install <name> HelmCharts -f <path_file_values>
```
и все заработает.

В реализации через HelmCharts первый под не стартует без второго, потому что HelmCharts более требователен к зависимостям между сущностями k8s. Если в каком-то манифесте прописан сервис, которого пока нет, то запуска не будет. Но из-за наличия Probe под никуда не исчезнет, он точно дождется запуска второго пода.

Но по хорошему надо еще сделать нормальный Volumes, например, через ```PersistentVolumes```. Тогда буду доволен.