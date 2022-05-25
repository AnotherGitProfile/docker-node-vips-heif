FROM node:16-buster

ARG LIBHEIF_VERSION=1.12.0
ARG VIPS_VERSION=8.12.2

# Install vips and heif dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      wget \
      g++ \
      make \
      build-essential \
      pkg-config \
      libglib2.0-dev \
      libexpat1-dev \
      libtiff5-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      libgsf-1-dev \
      libimagequant-dev \
      libimagequant0 \
      libwebp-dev \
      libx265-dev \
      libaom-dev \
      libde265-dev \
      gtk-doc-tools && \
    cd /tmp && \
    wget --quiet https://github.com/strukturag/libheif/releases/download/v${LIBHEIF_VERSION}/libheif-${LIBHEIF_VERSION}.tar.gz && tar xf libheif-${LIBHEIF_VERSION}.tar.gz && \
    wget --quiet https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz && tar xf vips-${VIPS_VERSION}.tar.gz

# Install HEIF library
RUN cd /tmp/libheif-${LIBHEIF_VERSION} && \
   ./autogen.sh && \
   ./configure && \
   make && \
   make install && \
   cp libheif.pc /usr/local/lib/pkgconfig/libheif.pc

# Install VIPS library
RUN cd /tmp/vips-${VIPS_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig /usr/local/lib

RUN apt-get -y --purge autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/*
