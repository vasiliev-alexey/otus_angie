# Запуск статического сайта

## Цель:
Создать базовую конфигурацию для работы статического сайта с разделением `location`.

## Описание/Пошаговая инструкция выполнения домашнего задания:

### Инструкция:

1. **Запустите статический сайт**, приложенный в дополнительных материалах к занятию, на сервере.

2. **Создайте отдельный `location` для каждой директории** со своими настройками:
    - Пример: для папки с CSS файлами, шрифтами и скриптами.

3. **Создайте `location` с регулярным выражением для отдачи изображений** форматов `jpg`, `jpeg`, `png`, `gif`.

4. **Используйте переменные, определённые с помощью `map`**, для настройки логики в разных `location`.

5. **Настройте два вида перенаправлений**:
    - **Постоянное (301)** — для случаев, когда необходимо навсегда перенаправить пользователя на новый URL.
    - **Временное (302)** — для случаев временных перенаправлений.
    - **Внутренние перенаправления** — для внутренних переходов внутри сайта.

---
## Решение

1. Создаем [docker-compose](docker-compose.yml) файл для  запуска статического сайта
2. Создаем директорию со статическими файлами и помещаем в нее [нужные файлы)](html)
3. Создаем конфигурационный файл [angie.conf](config/angie.conf) и помещаем в него [список настройок](config/angie.conf)
<details>
<summary>Подробнее</summary>

```yaml

worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    root /usr/share/angie/html;

    # Определяем переменные с помощью map
    map $request_uri $assets_dir {
        default "assets";
    }

    map $request_uri $css_dir {
        default "assets/css";
    }

    map $request_uri $fonts_dir {
        default "assets/fonts";
    }

    map $request_uri $js_dir {
        default "assets/js";
    }

    map $request_uri $images_dir {
        default "images";
    }

    server {
        listen       80;
        server_name  localhost;


        # Перенаправление favicon.ico на favicon-16x16.png
        location = /favicon.ico {
            rewrite ^/favicon.ico$ /favicon-16x16.png last;  # Внутреннее перенаправление
            log_not_found off;                              # Отключаем логирование, если файл не найден
            access_log off;                                 # Отключаем логирование доступа
        }

        # Обработка favicon-16x16.png
        location = /favicon-16x16.png {
            root /usr/share/angie/html/images/favicons; # Укажите путь к папке с изображениями
            log_not_found off;              # Отключаем логирование, если файл не найден
            access_log off;                 # Отключаем логирование доступа
        }


        # Главная страница
        location / {
            index index.html;
        }

        # Директория /assets/css
        location /$css_dir/ {
            autoindex on;           # Включаем показ содержимого директории
            try_files $uri $uri/ =404; # Проверяем наличие файлов
        }

        # Директория /assets/fonts
        location /$fonts_dir/ {
            autoindex off;          # Отключаем показ содержимого директории
            try_files $uri $uri/ =404;
        }

        # Директория /assets/js
        location /$js_dir/ {
            autoindex off;
            try_files $uri $uri/ =404;
        }

        location ~* \.(jpg|jpeg|png|gif)$ {
            root   /usr/share/angie/html; # Укажите путь к папке с изображениями
            expires 30d;                    # Устанавливаем кэширование изображений на 30 дней
            access_log off;                 # Отключаем логирование доступа к изображениям
        }

        # Директория /images
        location /$images_dir/ {
            autoindex on;
            try_files $uri $uri/ =404;
        }

        # Директория /error
        location /error/ {
            index index.html;
            internal;               # Внутреннее перенаправление
        }

        # Обработка ошибок 500, 502, 503, 504
        error_page  500 502 503 504 /50x.html;
        location = /50x.html {
            root   error/index.html;
        }

        # Обработка ошибок 404
        error_page 404 /error/index.html;
        location = /error/index.html {
            internal;               # Внутреннее использование страницы ошибки
        }


        # Внутреннее перенаправление
        location /old-page {
            rewrite ^/old-page$ / redirect; # Внутреннее перенаправление на новую страницу
        }

        # Внешнее перенаправление (301)
        location /redirect-permanent {
            return 301 https://otus.ru/lessons/angie/; # Постоянное перенаправление на новый URL
        }

        # Внешнее перенаправление (302)
        location /redirect-temporary {
            return 302 https://otus.ru/lessons/angie/; # Временное перенаправление
        }
    }
}


```


</details>


4. Запускаем контейнер для запуска статического сайта

```sh
docker-compose up -d 
```

5. Проверяем работу (видим что успешно работает)

* [Сайт](http://localhost:)  
* [Ошибка отсутствия](http://localhost/no_data_found)
* [Редирект (301)](http://localhost/redirect-permanent)
* [Редирект (302)](http://localhost/redirect-temporary)
* [Внутреннее перенаправление](http://localhost/old-page)







