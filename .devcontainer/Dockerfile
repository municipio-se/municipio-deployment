ARG imageVariant
FROM mcr.microsoft.com/devcontainers/php:1-${imageVariant}

# Install packages including libzip-dev before PHP extensions
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y mariadb-client libpng-dev apache2 libfreetype6-dev libjpeg-dev libwebp-dev libmagickwand-dev imagemagick libzip-dev \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install php-mysql driver and additional PHP modules
RUN docker-php-ext-install mysqli pdo pdo_mysql pcntl exif zip intl

# Install Image magick for php 8.3
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

# Install GD 
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd

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

# Install github cli
RUN (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# Install PHP tidy extension
RUN apt-get update && apt-get install -y libtidy-dev \
    && docker-php-ext-install tidy

RUN a2enmod headers mime rewrite ssl
RUN a2ensite default-ssl
