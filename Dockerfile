FROM ubuntu:20.04

ENV TZ="America/Sao_Paulo"
ENV LANG "pt_BR"

WORKDIR /var/www/html

RUN set -x \
    && addgroup --system --gid 101 nginx \
    && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx

RUN apt-get update
RUN apt-get install -y software-properties-common apt-utils net-tools

RUN apt-get install -y iputils-ping redis-tools \
curl gnupg2 ca-certificates lsb-release \
apt-transport-https ubuntu-keyring cron zip unzip supervisor

RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
| tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list

RUN ubuntu echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n"  | tee /etc/apt/preferences.d/99nginx

RUN apt-get update
RUN apt-get install -y nginx

RUN add-apt-repository -y ppa:ondrej/php

RUN apt-get update && apt-get install -y php8.1-fpm php8.1

RUN apt-get install -y php8.1-bcmath php8.1-cli php8.1-curl php8.1-dev php8.1-gd \
    php8.1-imap php8.1-intl php8.1-mbstring php8.1-mysql \
    php8.1-pgsql php8.1-pspell php8.1-xml php8.1-xmlrpc \
    php8.1-zip php8.1-common php8.1-apcu \
    php8.1-common php8.1-igbinary php8.1-memcached php8.1-msgpack php8.1-redis

# RUN cp /configs/nginx.conf /etc/nginx/conf.d/default.conf
# RUN cp /configs/php-fpm_www.conf /etc/php/8.1/fpm/pool.d/www.conf

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
RUN composer self-update

RUN apt-get update && apt-get install -y git

RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN php-fpm8.1 -t

RUN /etc/init.d/php8.1-fpm start

CMD ["nginx", "-g", "daemon off;"]

RUN apt-get update && apt-get install -y openssh-server

# RUN ufw allow ssh

RUN systemctl enable ssh

# RUN ubuntu systemctl ssh start