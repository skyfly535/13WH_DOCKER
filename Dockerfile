FROM nginx
# создаём 2 каталога в которых будур размещены наши web-страницы. Удаляем дефолтный conf NGINX.
RUN mkdir -p /usr/share/nginx/html1 && mkdir -p /usr/share/nginx/html2 && rm /etc/nginx/conf.d/default.conf
# Копируем настроенный conf с хостовой машины.
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
# указывает на необходимость открыть порт.
EXPOSE 80 3000

