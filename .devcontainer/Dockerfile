ARG imageVariant
FROM mcr.microsoft.com/devcontainers/php:1-${imageVariant}

# Replaces invalid key. Required to use apt-get when running this PHP 7.4 image.
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#     echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y mariadb-client libpng-dev apache2 bash-completion subversion \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install php-mysql driver
RUN docker-php-ext-install mysqli pdo pdo_mysql pcntl gd

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install WP CLI completions
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash \
    && mv wp-completion.bash /etc/bash_completion.d/wp-completion.bash

# Generate self-signed SSL certificate and add to site conf
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=example.com" \
    && sed -i 's/SSLCertificateFile\t\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/SSLCertificateFile \/etc\/ssl\/certs\/apache-selfsigned.crt/g' /etc/apache2/sites-available/default-ssl.conf \
    && sed -i 's/SSLCertificateKeyFile \/etc\/ssl\/private\/ssl-cert-snakeoil.key/SSLCertificateKeyFile \/etc\/ssl\/private\/apache-selfsigned.key/g' /etc/apache2/sites-available/default-ssl.conf

RUN a2enmod headers mime rewrite ssl
RUN a2ensite default-ssl

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
