#!/usr/bin/env bash
# Generate self-signed certs for Kodi
# Adapted from https://www.server-world.info/en/note?os=Fedora_36&p=ssl&f=1

set -e

main() {
    cd ~/.kodi/userdata/
    local PASSWORD="vastly-slick-grunge-eatable"
    PASSWORD="pass:${PASSWORD}"

    rm -f server.{key,pem,crt,csr}
    openssl genrsa -passout "${PASSWORD}" -aes128 2048  > server.key
    openssl rsa \
        -passin "${PASSWORD}" -in server.key \
        -passout "${PASSWORD}" -out server.key
    echo -e "us\nca\n\n\n\n\n\n\n\n" |\
        openssl req -utf8 -new -key server.key -out server.csr
    openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 3650
    chmod 600 server.key
    cp server.{crt,pem}

    echo "Finished generating self-signed certs"
}

main "${@}"
