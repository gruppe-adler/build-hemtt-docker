FROM debian:stretch
LABEL maintainer "Willard"

# Install needed packages
RUN apt update
RUN apt install -y build-essential software-properties-common pkg-config \
git g++-mingw-w64 \
openssl* libssl-dev curl \
cargo rustc

# Create 'workdir'
RUN mkdir /usr/local/dev
WORKDIR /usr/local/dev

# Cross compile OpenSSL for Win64
RUN git clone https://github.com/openssl/openssl.git && \
cd openssl && \
git checkout OpenSSL_1_1_1-stable && \
git pull && \
./Configure mingw64 --cross-compile-prefix=x86_64-w64-mingw32- --prefix=/usr/local/dev/openssl_static_x64 no-shared && \
make && \
make install

# Install rustup and install the Windows cross compilation target
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN $HOME/.cargo/bin/rustup target add x86_64-pc-windows-gnu

# Clone HEMTT
RUN git clone https://github.com/synixebrett/HEMTT.git && \
cd HEMTT && \
git pull origin master

# Build HEMTT to build deps
WORKDIR /usr/local/dev/HEMTT
RUN $HOME/.cargo/bin/cargo build --release

# Build HEMTT to build deps for Win64
ENV OPENSSL_DIR='/usr/local/dev/openssl_static_x64'
ENV OPENSSL_LIBS='ssl:crypto'
ENV OPENSLL_STATIC='1'
RUN $HOME/.cargo/bin/cargo rustc --release --target=x86_64-pc-windows-gnu -- -C linker=x86_64-w64-mingw32-gcc

# Copy and run the HEMTT build script
COPY ./build-hemtt.sh /
RUN chmod +x /build-hemtt.sh
ENTRYPOINT ["/build-hemtt.sh"]
VOLUME /usr/share/target
