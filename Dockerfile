FROM node:16-bullseye

ARG VIPS_VERSION=8.14.2
ARG LIBHEIF_VERSION=1.16.2

# Install vips and heif dependencies
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  wget \
  g++ \
  libc6 \
  make \
  cmake \
  meson \
  yasm \
  ninja-build \
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
  libde265-dev \
  libgirepository1.0-dev \
  libfftw3-dev \
  libexif-dev \
  liborc-0.4-dev \
  liblcms2-dev \
  librsvg2-dev \
  libffi-dev \
  libopenjp2-7-dev \
  gtk-doc-tools && \
  echo 'deb http://ftp.debian.org/debian bookworm main' > /etc/apt/sources.list.d/bookworm.list && \
  echo 'APT::Default-Release "stable";' > /etc/apt/apt.conf.d/default-release && \
  apt-get update -qq && \
  apt-get -t bookworm install -qqy libcgif-dev && \
  rm /etc/apt/sources.list.d/bookworm.list && \
  rm /etc/apt/apt.conf.d/default-release && \
  rm -rf /var/lib/apt/lists/* && \
  cd /tmp && \
  wget --quiet https://github.com/strukturag/libheif/releases/download/v${LIBHEIF_VERSION}/libheif-${LIBHEIF_VERSION}.tar.gz && tar xf libheif-${LIBHEIF_VERSION}.tar.gz && \
  wget --quiet https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz && tar xf vips-${VIPS_VERSION}.tar.xz

# Install HEIF library
RUN cd /tmp/libheif-${LIBHEIF_VERSION} && \
  mkdir build && \
  cd build && \
  cmake --preset=release .. && \
  make && \
  make install && \
  cp libheif.pc /usr/local/lib/pkgconfig/libheif.pc

# Install VIPS library
RUN cd /tmp/vips-${VIPS_VERSION} && \
  meson setup build --buildtype=release -Dintrospection=false && \
  cd build && \
  ninja && \
  ninja test && \
  ninja install && \
  ldconfig

RUN apt-get -y --purge autoremove && \
  apt-get -y clean && \
  rm -rf /tmp/*
