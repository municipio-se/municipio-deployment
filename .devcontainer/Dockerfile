FROM mcr.microsoft.com/devcontainers/php:1-8.3-bullseye

# Replaces invalid key. Required to use apt-get when running this PHP 7.4 image.
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#     echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y mariadb-client libpng-dev \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install php-mysql driver
RUN docker-php-ext-install mysqli pdo pdo_mysql pcntl gd

# Install additional packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends bash-completion subversion

# Set up self signed SSL certificate and enable SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost" \
   && a2enmod ssl \
   && a2ensite default-ssl

# Add self signed ssl certificate to site config
RUN sed -i 's/SSLCertificateFile.*/SSLCertificateFile \/etc\/ssl\/certs\/localhost.crt/g' /etc/apache2/sites-available/default-ssl.conf \
    && sed -i 's/SSLCertificateKeyFile.*/SSLCertificateKeyFile \/etc\/ssl\/private\/localhost.key/g' /etc/apache2/sites-available/default-ssl.conf

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install WP CLI completions
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash \
    && mv wp-completion.bash /etc/bash_completion.d/wp-completion.bash

RUN a2enmod headers mime rewrite

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
