ARG imageVariant
FROM mcr.microsoft.com/devcontainers/php:1-${imageVariant}

RUN curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --yes --dearmor -o /usr/share/keyrings/yarnkey.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list > /dev/null

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

# Enable Apache modules for development (removed SSL)

# Install github cli
RUN (type -p wget >/dev/null || (apt update && apt install wget -y)) \
	&& mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& apt update \
	&& apt install gh -y

# Install PHP tidy extension
RUN apt-get update && apt-get install -y libtidy-dev \
    && docker-php-ext-install tidy

# Increase php upload limit
RUN echo "upload_max_filesize = 256M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 256M" >> /usr/local/etc/php/conf.d/uploads.ini

RUN a2enmod headers mime rewrite
