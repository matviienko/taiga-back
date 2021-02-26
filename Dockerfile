FROM python:3.6
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /tmp
###
RUN set -x; apt-get update
RUN apt-get install -y nodejs npm nginx
RUN npm install -g gulp npm@latest
RUN apt-get install -y --no-install-recommends \
        locales \
        gettext \
        ca-certificates \
        # nginx=${NGINX_VERSION} \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
###
ENV TAIGA_HOSTNAME localhost
ENV TAIGA_FRONT_HOSTNAME=$TAIGA_HOSTNAME
ARG TAIGA_SCRIPT_REPOSITORY=git@github.com:taigaio/taiga-scripts.git
###
ARG TAIGA_BACK_REPOSITORY=git@github.com:taigaio/taiga-back.git
ENV TAIGA_BACK_REPOSITORY=$TAIGA_BACK_REPOSITORY
ARG TAIGA_BACK_BRANCH=stable
ENV TAIGA_BACK_BRANCH=$TAIGA_BACK_BRANCH
###
ARG TAIGA_FRONT_DIST_REPOSITORY=git@github.com:taigaio/taiga-front-dist.git
ENV TAIGA_FRONT_DIST_REPOSITORY=$TAIGA_FRONT_DIST_REPOSITORY
ARG TAIGA_FRONT_DIST_BRANCH=stable
ENV TAIGA_FRONT_DIST_BRANCH=$TAIGA_FRONT_DIST_BRANCH
###
ARG TAIGA_FRONT_REPOSITORY=git@github.com:taigaio/taiga-front.git
ENV TAIGA_FRONT_REPOSITORY=$TAIGA_FRONT_REPOSITORY
ARG TAIGA_FRONT_BRANCH=stable
ENV TAIGA_FRONT_BRANCH=$TAIGA_FRONT_BRANCH
###
ENV TAIGA_SSL False
ENV TAIGA_SSL_BY_REVERSE_PROXY False
ENV TAIGA_ENABLE_EMAIL False
ENV TAIGA_SECRET_KEY "!!!REPLACE-ME-j1598u1J^U*(y251u98u51u5981urf98u2o5uvoiiuzhlit3)!!!"
###
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
###
COPY . /usr/src/taiga-back
###
RUN mkdir -p /taiga
COPY docker/conf/taiga/local.py /taiga/local.py
# COPY conf/taiga/conf.json /taiga/conf.json
# RUN ln -s /taiga/local.py /usr/src/taiga-back/settings/local.py
# RUN ln -s /taiga/conf.json /usr/src/taiga-front-dist/dist/conf.json
###
# COPY taiga-back /usr/src/taiga-back
# COPY taiga-front-dist/ /usr/src/taiga-front-dist
COPY docker/docker-settings.py /usr/src/taiga-back/settings/docker.py
COPY docker/conf/locale.gen /etc/locale.gen
COPY docker/conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/conf/nginx/taiga.conf /etc/nginx/conf.d/default.conf
COPY docker/conf/nginx/ssl.conf /etc/nginx/ssl.conf
COPY docker/conf/nginx/taiga-events.conf /etc/nginx/taiga-events.conf
# # Backwards compatibility
# RUN mkdir -p /usr/src/taiga-front-dist/dist/js/
# RUN ln -s /taiga/conf.json /usr/src/taiga-front-dist/dist/js/conf.json
COPY docker/checkdb.py /checkdb.py
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
###
WORKDIR /usr/src/taiga-back
EXPOSE 80 443
VOLUME /usr/src/taiga-back/media
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
