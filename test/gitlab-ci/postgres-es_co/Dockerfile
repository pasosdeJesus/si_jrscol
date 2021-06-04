# Extiende imagen de Postgres con locale es_CO.UTF-8 
# Basado en ejemplos de https://hub.docker.com/_/postgres/ y

FROM postgres:13.3
RUN localedef -i es_CO -c -f UTF-8 -A /usr/share/locale/locale.alias es_CO.UTF-8
ENV LANG es_CO.utf8
