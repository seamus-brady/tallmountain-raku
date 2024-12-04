# Use the official Rakudo Star image
FROM rakudo-star:latest

RUN apt update && \
    apt upgrade -y && \
    apt install -y curl uuid-dev libpq-dev libssl-dev unzip build-essential zip && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy your project files into the container
COPY ./bin /app/bin
COPY ./config /app/config
COPY ./lib /app/lib
COPY ./t /app/t
COPY ./META6.json /app
COPY ./www /app/www

RUN git clone https://github.com/ugexe/zef.git /tmp/zef && \
    cd /tmp/zef && \
    raku -I. bin/zef install . --/test

# install dependencies not in raku.land
RUN git clone https://github.com/JuneKelly/perl6-config-clever && \
    cd perl6-config-clever && \
    zef install .

RUN git clone https://github.com/skinkade/crypt-random && \
    cd crypt-random  && \
    zef install .

# Install project dependencies
RUN zef install --verbose --force --/test Array::Circular
ARG cro_version=0.8.9
RUN zef install 'Cro::Core:ver<'$cro_version'>'
RUN zef install --/test 'Cro::HTTP:ver<'$cro_version'>'
RUN zef install --verbose --force --/test --deps-only .

# Expose any necessary ports (optional)
# EXPOSE 8080

# Set the default command to run your Raku application
CMD ["raku", "/app/bin/app"]
