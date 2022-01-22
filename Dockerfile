#
# Build Image
#

FROM alpine:3.8 as builder

# Dependencies needed for building Mapcrafter
# (not sure how many of these are actually needed)
RUN apk add \
        git \
        cmake \
        gcc \
        make \
        g++ \
        zlib-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        boost-dev

RUN mkdir /git && cd /git && \
    git clone --single-branch --branch world118 https://github.com/miclav/mapcrafter.git
# Build mapcrafter from source
RUN cd /git/mapcrafter && \
    mkdir build && cd build && \
    cmake .. && \
    make && \
    mkdir /tmp/mapcrafter && \
    make DESTDIR=/tmp/mapcrafter install


#
# Final Image
#

FROM alpine:3.8

# Mapcrafter, built in previous stage
COPY --from=builder /tmp/mapcrafter/ /

# Depedencies needed for running Mapcrafter
RUN apk --no-cache add \
        libpng \
        libjpeg-turbo \
        boost \
        boost-iostreams \
        boost-system \
        boost-filesystem \
        boost-program_options \
        shadow \
        dcron \
        libcap


ADD crontab /etc/cron.d/mapcrafter-cron
ADD render.sh /render
ADD render.conf /config/render.conf
ADD entrypoint.sh /

RUN chmod 0644 /etc/cron.d/mapcrafter-cron; useradd service; chmod 0777 /render; chmod +x entrypoint.sh; 

ENTRYPOINT /entrypoint.sh
