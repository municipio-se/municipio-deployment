ARG imageVariant
FROM mcr.microsoft.com/devcontainers/php:1-${imageVariant}

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y mariadb-client libpng-dev apache2 libfreetype6-dev libjpeg-dev libwebp-dev libmagickwand-dev imagemagick \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install php-mysql driver
RUN docker-php-ext-install mysqli pdo pdo_mysql pcntl

#install Image magick for php 8.3
RUN git clone https://github.com/Imagick/imagick.git --depth 1 /tmp/imagick && \
    cd /tmp/imagick && \
    git fetch origin master && \
    git switch master && \
    cd /tmp/imagick && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    apt-get remove -y git && \
    apt-get autoremove -y && \
    docker-php-ext-enable imagick && \
    rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install git completions
RUN curl -o ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    && echo "source ~/.git-completion.bash" >> ~/.bashrc

# Install WP CLI completions
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash \
    && mv wp-completion.bash /etc/bash_completion.d/wp-completion.bash \
    && echo "source /etc/bash_completion.d/wp-completion.bash" >> ~/.bashrc

# Generate self-signed SSL certificate and add to site conf
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=example.com" \
    && sed -i 's/SSLCertificateFile\t\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/SSLCertificateFile \/etc\/ssl\/certs\/apache-selfsigned.crt/g' /etc/apache2/sites-available/default-ssl.conf \
    && sed -i 's/SSLCertificateKeyFile \/etc\/ssl\/private\/ssl-cert-snakeoil.key/SSLCertificateKeyFile \/etc\/ssl\/private\/apache-selfsigned.key/g' /etc/apache2/sites-available/default-ssl.conf

RUN a2enmod headers mime rewrite ssl
RUN a2ensite default-ssl
