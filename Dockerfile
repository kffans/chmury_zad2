FROM alpine:latest as build
LABEL org.opencontainers.image.authors="Jakub Kwandrans"

# pobranie nginx
RUN apk add --no-cache nginx

# plik aplikacji internetowej
COPY ./src/index.html /usr/share/nginx/html/index.html
# plik konfiguracyjny nginx
COPY ./src/nginx.conf /etc/nginx/nginx.conf


FROM scratch

# kopiowanie niezbędnych plików z alpine do scratch
COPY --from=build /etc/passwd /etc/
WORKDIR /etc/nginx
COPY --from=build . /
WORKDIR /usr/sbin
COPY --from=build . /
WORKDIR /usr/share/nginx
COPY --from=build . /

# port 80
EXPOSE 80

HEALTHCHECK --interval=10s --timeout=1s \
   CMD curl -f http://localhost/index.html/ || exit 1

# uruchomienie nginx
CMD [ "/usr/sbin/nginx" , "-g" , "daemon off;" ]

