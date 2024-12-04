# Use the official Rakudo Star image
FROM rakudo-star:latest

ARG OPENAI_API_KEY_ARG
ENV OPENAI_API_KEY=$OPENAI_API_KEY_ARG
# RUN echo "The OPENAI_API_KEY is $OPENAI_API_KEY"

RUN apt update && \
    apt upgrade -y && \
    apt install -y curl uuid-dev libpq-dev libssl-dev unzip build-essential zip libxml2-dev && \
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

# install dependencies not in raku.land or that cause issues
RUN git clone https://github.com/JuneKelly/perl6-config-clever && \
    cd perl6-config-clever && \
    zef install .

RUN git clone https://github.com/skinkade/crypt-random && \
    cd crypt-random  && \
    zef install .

RUN git clone https://github.com/JJ/Raku-Digest-HMAC.git && \
    cd Raku-Digest-HMAC && \
    zef install .

RUN git clone https://github.com/retupmoca/p6-markdown.git && \
    cd p6-markdown && \
    zef install .

# Install project dependencies
RUN zef install --verbose --force --/test Array::Circular
RUN zef install --verbose --force --/test Docker::File
RUN zef install --verbose --force --/test File::Ignore
RUN zef install --verbose --force --/test IO::Socket::Async::SSL
RUN zef install --verbose --force --/test Digest::SHA1::Native
RUN zef install --verbose --force --/test JSON::Unmarshal
RUN zef install --verbose --force --/test JSON::Fast
RUN zef install --verbose --force --/test OO::Monitors
RUN zef install --verbose --force --/test Shell::Command
RUN zef install --verbose --force --/test DBIish::Pool
RUN zef install --verbose --force --/test JSON::JWT
RUN zef install --verbose --force --/test TinyFloats
RUN zef install --verbose --force --/test CBOR::Simple
RUN zef install --verbose --force --/test Log::Timeline
RUN zef install --verbose --force --/test Text::Markdown
RUN zef install --verbose --force --/test Terminal::ANSIColor
RUN zef install --verbose --force --/test Base64
RUN zef install --verbose --force --/test IO::Socket::SSL
RUN zef install --verbose --force --/test IO::Path::ChildSecure
RUN zef install --verbose --force --/test JSON::JWT
RUN zef install --verbose --force --/test HTTP::HPACK
RUN zef install --verbose --force --/test Cro::Core
RUN zef install --verbose --force --/test Cro::TLS
RUN zef install --verbose --force --/test https://github.com/croservices/cro-http.git
RUN zef install --verbose --force --/test App::Prove6
RUN zef install --verbose --force --/test Env::Dotenv
RUN zef install --verbose --force --/test HTTP::Tinyish
RUN zef install --verbose --force --/test JSON::Fast
RUN zef install --verbose --force --/test Logger
RUN zef install --verbose --force --/test UUID::V4
RUN zef install --verbose --force --/test W3C::DOM
RUN zef install --verbose --force --/test Method::Also

RUN git clone https://github.com/libxml-raku/LibXML-raku.git && \
    cd LibXML-raku && \
    zef install .

EXPOSE 10000

CMD ["raku", "/app/bin/app"]
