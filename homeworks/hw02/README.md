# Миграция из Nginx в Angie

## Описание/Пошаговая инструкция выполнения домашнего задания:

Инструкция:

1. Возьмите готовый набор конфигов для Nginx, вы найдёте его в дополнительных материалах к занятию.
2. Установите рядом Angie.
3. Перенесите все значимые параметры конфигурации из Nginx в Angie.
4. Дополнительно: автоматизируйте преобразование конфигов с помощью bash или другого скриптового языка.

---

## Решение

1. Создаем [стенд](Vagrantfile)
2. [Устанавливаем nginx, копируем конфиги](provisioners/base.yml)

```sh
 vagrant up --provision-with base      
```

3. Проверим ответ от Nginx c хостовой машины

```sh
➜  hw02 git:(hw02) ✗ curl -s -I  http://localhost:8080                                                                                                                                                                                                                                                                                                                                                   21:28:04 12/10/24
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Sat, 12 Oct 2024 18:28:42 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Sat, 12 Oct 2024 18:27:23 GMT
Connection: keep-alive
Vary: Accept-Encoding
ETag: "670abf8b-267"
Accept-Ranges: bytes
```

4. Запускаем [установку angie и миграцию](provisioners/angie.yml)

```sh
vagrant provision --provision-with angie  
```

5. Проверяем результат установки и миграции

```sh
 ➜  provisioners git:(hw02) ✗ curl -s -I  http://localhost:8080                                                                                                                                                                                                                                                                                                                                           21:30:32 12/10/24
HTTP/1.1 200 OK
Server: Angie/1.7.0
Date: Sat, 12 Oct 2024 18:30:45 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Sat, 12 Oct 2024 18:27:23 GMT
Connection: keep-alive
Vary: Accept-Encoding
ETag: "670abf8b-267"
Accept-Ranges: bytes
``` 

---