FROM nginx:alpine

ENV RANDOM_BEER https://api.punkapi.com/v2/beers/random
ENV STYLES https://rustybeer.herokuapp.com/styles

COPY ./proxy.conf.template /proxy.conf.template
COPY error.html /etc/nginx/html/error.html
COPY ./nginx.conf /etc/nginx/nginx.conf

COPY ./server.crt /etc/ssl/server.crt
COPY ./server.key /etc/ssl/server.key
COPY ./merged.crt /etc/nginx/client_certs/ca.crt

CMD ["/bin/sh" , "-c" , "envsubst '$$RANDOM_BEER $$STYLES ' < /proxy.conf.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]