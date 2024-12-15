# Защита от DoS-атак, ограничение доступа

## Цель:

Применить известные методы защиты от DoS-атак на приложение.

## Описание/Пошаговая инструкция выполнения домашнего задания:

### Инструкция:

1. Для запущенного ранее приложения найдите наиболее подверженные атаке location.
2. Настройте ограничение частоты запросов.
3. Запустите сервис fail2ban для автоматической блокировки атакующих на основе частоты запросов.
4. Настройте защищенный доступ в любой выбранный location с HTTP-авторизацией и ограничением доступа по IP.

### Критерии оценки:

Статус "Принято", если:

1. Настроено ограничение по частоте запросов.
2. Запущен сервис fail2ban и реализована автоматическая блокировка атакующих.
3. Настроена авторизация и ограничение доступа.

---  

## Решение

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

В консоли выполнения должно быть надпись с внешним IP созданной виртуалки c балансировщиком

```sh

Outputs:

Адрес-ip-LB = "89.169.159.80"

```

6. Проверяем работу (видим что успешно работает) - фронт загружается. Бекнд работает.

[http://89.169.159.80/](hhttp://89.169.159.80/)

7. Создаем тестового агента в сервисе нагрузочного тестирования

[Как начать работать с Yandex Load Testing](https://yandex.cloud/ru/docs/load-testing/quickstart?from=int-console-help-center-or-nav)

Конфигурация теста

```yaml
pandora:
  enabled: true
  package: yandextank.plugins.Pandora
  config_content:
    pools:
      - id: HTTP
        gun:
          type: http
          target: 158.160.32.16:80
          ssl: false
        ammo:
          type: uri
          uris:
            - /api/articles?limit=10&offset=0
        result:
          type: phout
          destination: ./phout.log
        startup:
          type: once
          times: 1000
        rps:
          - type: const
            ops: 300
            duration: 600s
        discard_overflow: true
    log:
      level: error
    monitoring:
      expvar:
        enabled: true
        port: 1234
autostop:
  enabled: true
  package: yandextank.plugins.Autostop
  autostop:
    - limit(5m)
core: { }

```

8. Проверяем состояние fail2ban на балансировщике

```SH
Status
|- Number of jail:      3
`- Jail list:   nginx-http-auth, nginx-limit-req, sshd
```

```SH
ubuntu@lb:~$ sudo fail2ban-client status nginx-limit-req
Status for the jail: nginx-limit-req
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     0
|  `- File list:        /var/log/angie/error.log
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:   

```

9. Запускаем тест с агента нагрузки (ip 130.193.48.35) и проверяем состояние

```SH
ubuntu@lb:~$ sudo fail2ban-client status nginx-limit-req
Status for the jail: nginx-limit-req
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     134
|  `- File list:        /var/log/angie/error.log
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   130.193.48.35

```

Как видим блокировка по IP сработала

Разблокируем IP

```SH
sudo fail2ban-client unban 130.193.48.35
```

10. проверим работу fail2ban для ауетентификации запросов

```SH
 sudo fail2ban-client stop nginx-limit-req

```

11. Правим тест для запросов с аутентификацией

```yaml
pandora:
  enabled: true
  package: yandextank.plugins.Pandora
  config_content:
    pools:
      - id: HTTP
        gun:
          type: http
          target: 158.160.32.16:80
          ssl: false
        ammo:
          type: uri
          uris:
            - /api/profiles/SSS
        result:
          type: phout
          destination: ./phout.log
        startup:
          type: once
          times: 1000
        rps:
          - type: const
            ops: 200
            duration: 600s
        discard_overflow: true
    log:
      level: error
    monitoring:
      expvar:
        enabled: true
        port: 1234
autostop:
  enabled: true
  package: yandextank.plugins.Autostop
  autostop:
    - limit(5m)
core: { }

```

12. Перезапускаем тест и смотри состояние nginx-http-auth

```SH
ubuntu@lb:~$ sudo fail2ban-client status nginx-http-auth
Status for the jail: nginx-http-auth
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     20
|  `- File list:        /var/log/angie/access.log
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   130.193.48.35

```

Как видимо наш нагрузочный агент попал в бан по аутентификации

![](https://icdn.lenta.ru/images/2021/10/21/11/20211021110546130/wide_16_9_da1f40493378e3e394057e8c97def081.jpeg)
