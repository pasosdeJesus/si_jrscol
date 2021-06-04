# Extiende imagen de Postgis con locale es_CO.UTF-8
# Basado en ejemplo de 
#  https://www.pietrangelo.net/20050/postgresql-docker-image-with-postgis-extension

FROM postgis/postgis:13-3.1

RUN localedef -i es_CO -c -f UTF-8 -A /usr/share/locale/locale.alias es_CO.UTF-8
ENV LANG es_CO.utf8
