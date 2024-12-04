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
COPY ./_scripts/install_deps.sh /app/install_deps.sh

RUN chmod +x /app/install_deps.sh

RUN /app/install_deps.sh

EXPOSE 10000

CMD ["raku", "/app/bin/app"]
