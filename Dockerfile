# Use the official Rakudo Star image
FROM rakudo-star:latest

RUN apt update && \
    apt upgrade -y && \
    apt install zip -y && \
    apt install build-essential -y && \
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

RUN zef upgrade zef

# install dependencies not in raku.land
RUN git clone https://github.com/JuneKelly/perl6-config-clever && \
    cd perl6-config-clever && \
    zef install .

RUN git clone https://github.com/skinkade/crypt-random && \
    cd crypt-random  && \
    zef install .

# Install project dependencies
RUN zef install --verbose --force --/test Array::Circular
RUN zef install --verbose --force --/test Docker::File
RUN zef install --verbose --force --/test File::Ignore
RUN zef install --verbose --force --/test IO::Socket::Async::SSL
RUN zef install --verbose --force --/test Digest::SHA1::Native
RUN zef install --debug --/test cro
RUN zef install --verbose --force --/test --deps-only .

# Expose any necessary ports (optional)
# EXPOSE 8080

# Set the default command to run your Raku application
CMD ["raku", "/app/bin/app"]
