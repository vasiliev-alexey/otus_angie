# Настройка HTTPS

## Цель:

Настроить эффективную и безопасную конфигурацию для HTTPS.

## Описание/Пошаговая инструкция выполнения домашнего задания:

### Инструкция:

1. Получите сертификат Let's encrypt или создайте самоподписной. Используйте домен при наличии.
2. Настройте основные параметры HTTPS в Angie.
3. Оптимизируйте восстановление сессий.
4. Включите автоматическую переадресацию с HTTP на HTTPS.
5. Настройте заголовок HSTS.
6. Включите протоколы HTTP/2 и HTTP/3.
7. Проведите тестирование корректности конфигурации с помощью внешнего сервиса.

### Критерии оценки:

Статус "Принято", если:

1. Сформирована корректная конфигурация HTTPS для сайта.
2. Получен или сформирован сертификат.
3. Реализовано перенаправление и настроен заголовок HSTS.

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

Адрес-ip-LB = "130.193.37.45"

```

6. Проверяем работу (видим что успешно работает) - фронт загружается. Бекнд работает.

[https://avvtech.store/](hhttps://avvtech.store/)