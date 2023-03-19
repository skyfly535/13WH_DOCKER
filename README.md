# Docker.
## Dockerfile
1. Написать Dockerfile на базе apache/nginx который будет содержать две статичные web-страницы на разных портах. Например, 80 и 3000.
2. Пробросить эти порты на хост машину. Обе страницы должны быть доступны по адресам
localhost:80 и localhost:3000.
3. Добавить 2 волюма. Один для логов приложения, другой для web-страниц.

Устанавливаем Docker согласно официальному мануалу https://docs.docker.com/engine/install/ubuntu/

Создаем рабочий каталог

```
mkdir docker
```
Переходим в него

```
cd docker
```

Создаем Dockerfile

```
touch Dockerfile
```
Создаем каталог для монтирования в контейнер, в котором будет лежать первая web-страница

```
mkdir html
```
Помещаем в него нашу web-страницу

```
<title>Welcome to education OTUS!</title>
<h1>Homework. !!! DOCKER !!! Page 1<h1>
    <h1>localhost:80 <h1></h1>
```

Создаем каталог для монтирования в контейнер, в котором будет лежать вторая web-страница

```
mkdir html1
```
Помещаем в него нашу web-страницу

```
<title>Welcome to education OTUS!</title>
<h1>Homework. !!! DOCKER !!! Page 2 <h1>
    <h1>localhost:3000 <h1></h1>
```
Создаем каталог для монтирования в контейнер, в который будут литься логи NGINX

```
mkdir log
```
Создаем файл `nginx.conf` конфигурирования наших серверов

```
# сервре с первой web-страницой
server {
            # порт прослушки
            listen       80;
            listen  [::]:80;
            server_name  localhost;
            access_log  /var/log/nginx/host.access.log  main;

                location / 
                    {
                        # каталог хранения файла страницы
                        root   /usr/share/nginx/html1;
                        index  index.html index.htm;
                    }
        }
# сервре с второй web-страницой
server { 
            # порт прослушки
            listen       3000;
            listen  [::]:3000;
            server_name  localhost;
            access_log  /var/log/nginx/host.access.log  main;

                location / 
                    {
                        # каталог хранения файла страницы
                        root   /usr/share/nginx/html2;
                        index  index.html index.htm;
                    }
        }
```
Базовый образ берем NGINX и добавляем необходимы функции (опции) для работы будующего контейнера

```
FROM nginx
# создаём 2 каталога в которых будур размещены наши web-страницы. Удаляем дефолтный conf NGINX.
RUN mkdir -p /usr/share/nginx/html1 && mkdir -p /usr/share/nginx/html2 && rm /etc/nginx/conf.d/default.conf
# Копируем настроенный conf с хостовой машины.
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
# указывает на необходимость открыть порт.
EXPOSE 80 3000
```


Билдим образ контейнера из Dockerfile

```
docker build -t otus7 .
```
Запускаем контейнер из собранного образа. Параметры запуска:

1. -p 80:80 - праброска портов для первого web-сервера
2. -p 3000:3000 - праброска портов для второго web-сервера
3. -v ./log:/var/log/nginx - монируем  каталог для логов NGINX
4. -v ./html:/usr/share/nginx/html1:ro - монтируем каталог с первой web-страницой (права из контейнера только на чтение)
5. -v ./html1:/usr/share/nginx/html2:ro - монтируем каталог с второй web-страницой (права из контейнера только на чтение)

```
docker run -p 80:80 -p 3000:3000 -v ./log:/var/log/nginx -v ./html:/usr/share/nginx/html1:ro -v ./html1:/usr/share/nginx/html2:ro  otus7
```
Результат запуска контейнера смотрим в браузере.

Первый сервер


Второй серврер

## Docker-compose

1. Написать Docker-compose для приложения Redmine.
2. Добавить в базовый образ redmine любую кастомную тему оформления.
3. Использовать опцию build.
4. Убедиться что после сборки новая тема доступна в настройках.

Создаем в нашем каталоге файл `Docker-compose.yaml`

```
touch docker-compose.yaml
```

и создаем в нем следующую структуру

```
version: "3.3"
services:
  # билдим Dockerfile из первой части ДЗ
  otus:
    build:
      context: .
    #  указывает на необходимость открыть порты 
    ports:
      - "3000:3000"
      - "80:80"
    # создаем точки монтирования  
    volumes:
      # монтируем на хост каталог логов NGINX
      - ./log:/var/log/nginx
      # монтируем каталог с файлом первой web-страницы (права только на чтение)
      - ./html:/usr/share/nginx/html1:ro
      # монтируем каталог с файлом второй web-страницы (права только на чтение)
      - ./html1:/usr/share/nginx/html2:ro
  # разворачиваем контейнер Redmine
  redmine:
    image: redmine
    # режим запуска
    restart: always
    #  указывает на необходимость открыть порт
    ports:
      - 8080:3000
    volumes:
      # создаем точку монтирования (каталог на хостовой машине, где будут находится кастомные темы) 
       - ./redmine-themes:/usr/src/redmine/public/themes
    # объявляем переменные окружения необходимые для подключения БД
    environment:
      REDMINE_DB_MYSQL: db
      REDMINE_DB_PASSWORD: example
      REDMINE_SECRET_KEY_BASE: supersecretkey
  # разворачиваем контейнер Mysql
  db:
    image: mysql:5.7
    # режим запуска
    restart: always
    # объявляем переменные окружения необходимые для запуска БД
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: redmine
```

Проверяем запущенный контейнер из первой части ДЗ

```
docker ps
```

Останавливаем его и удаляем

```
docker stop <id контейнера>

docker rm <id контейнера>
```

Проверяем и удаляем собранный в первой части ДЗ образ контейнера

```
docker images 

docker rmi <id образа>
```

Создаем каталог для монтирования в контейнер redmine, в который будут находится файлы кастомной темы

```
mkdir redmine-themes
```
Далее идем на https://www.redminethemes.org/ и выбираем тему.

Я выбрал эту https://www.redminethemes.org/redmine-themes/redpenny-theme.

Далее автор темы нас отправляем на `GitHub` https://github.com/themondays/redpenny/blob/master/README.md

Действуем по инструкции.

Переходим в каталог `redmine-themes`

```
cd redmine-themes
```

Забираем тело темы в каталог

```
git clone http://github.com/themondays/redpenny.git redpenny
``` 

Поднимаем структуру

```
docker-compose up
```
Идем на http://127.0.0.1:8080, смотрим результат


Смотрим сисок тем


Устанавливаем скаченную тему