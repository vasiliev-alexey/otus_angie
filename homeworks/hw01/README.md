# Установка Angie

## Цель:

Провести установку актуальной версии Angie на виртуальную машину различными способами.

## Описание/Пошаговая инструкция выполнения домашнего задания:

1. Подключите в систему (Яндекс.Облако или локальный ВМ) официальный репозиторий Angie.
2. Установите Angie и несколько дополнительных (на выбор) модулей из репозитория.
3. Запустите Angie из Docker-образа. Необходимо вынести конфигурацию в хостовую директорию и указать проброс портов в
   хостовую сеть для HTTP/HTTPS.

Форма сдачи: в чат проверки домашнего задания отправьте ссылку на репозиторий GitHub, где задокументировано решение ДЗ.
Проверьте, чтобы по ссылке был открыт доступ.

---  

### Решение в облаке

1. Регистрируемся в облачном сервисе Yandex Cloud

2. Создаем Folder в облачном сервисе

2. Создаем сервисный аккаунт

```sh
yc iam service-account create --name otus-hl-sa


yc iam service-account list

yc iam service-account list                                                                                                                                                                                                                                                                                       
+----------------------+------------+--------+
|          ID          |    NAME    | LABELS |
+----------------------+------------+--------+
| aje...ed5 | otus-hl-sa |        |
+----------------------+------------+--------+

yc iam key create   --service-account-id aje...ed5  --folder-id b1....et2   --output key.json

yc config set service-account-key key.json


```

3. Назначаем роли для сервисного аккаунта на папку - default

```sh
yc resource-manager folder add-access-binding default   --role admin   --subject serviceAccount:aje...ed5
```

4. Выставляем переменные для terraform скрипта в переменные среды

```sh
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)                                                
```

5. Запускаем terraform

``` sh
terraform  apply -var-file="yc.tfvars"                 
```

В консоли выполнения должно быть надпись с внешним IP созданной виртуалки

```sh
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

instance_external_ip = "89.169.147.183"
```

6. Проверяем работу (видим что успешно работает)

```sh
curl -s -I http://89.169.147.183      
```

```html
HTTP/1.1 200 OK
Server: Angie/1.7.0
Date: Sat, 12 Oct 2024 11:05:00 GMT
Content-Type: text/html
Content-Length: 18
Last-Modified: Sat, 12 Oct 2024 09:58:07 GMT
Connection: keep-alive
ETag: "670a482f-12"
Accept-Ranges: bytes
```

```sh
curl  http://89.169.147.183
```

```html
<h1>Hello hw1</h1>%    
```

### Решение в Docker

1. Создаем [docker-compose.yml](https://docs.docker.com/compose/compose-file/) файл
2. Запускаем `docker-compose up`
```sh
Creating network "docker_webnet" with driver "bridge"
Creating angie_server ... done
```
3. Проверяем работу (видим что успешно работает)
```sh
 curl http://localhost       
```

```html
<h1>hello from docker</h1>%     
```

```sh
 curl -s -I  http://localhost          
```

```html
HTTP/1.1 200 OK
Server: Angie/1.7.0
Date: Sat, 12 Oct 2024 11:10:41 GMT
Content-Type: text/html
Content-Length: 26
Last-Modified: Fri, 11 Oct 2024 20:06:27 GMT
Connection: keep-alive
ETag: "67098543-1a"
Accept-Ranges: bytes

```

---