FROM alpine:3.20

RUN apk update
RUN apk add git
RUN apk add curl
RUN apk add just

RUN apk add --no-cache rust cargo

ENV PATH="/root/.cargo/bin:$PATH" 
RUN apk add openssl openssl-dev
RUN cargo install --locked typst-cli
RUN cargo install --locked --git https://github.com/tingerrr/typst-test --tag ci-semi-stable