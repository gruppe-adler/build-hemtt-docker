#!/bin/bash

# Switch into the 'workdir'
cd /usr/local/dev/HEMTT

# Pull HEMTT
git pull origin master

# Build for Linux
unset OPENSSL_DIR
unset OPENSSL_LIBS
unset OPENSLL_STATIC
$HOME/.cargo/bin/cargo build --release

# Build for Windows
export OPENSSL_DIR='/usr/local/dev/openssl_static_x64'
export OPENSSL_LIBS='ssl:crypto'
export OPENSLL_STATIC='1'
$HOME/.cargo/bin/cargo rustc --release --target=x86_64-pc-windows-gnu -- -C linker=x86_64-w64-mingw32-gcc

# Copy the executables to the volume
cp target/release/hemtt /usr/share/target/hemtt
cp target/x86_64-pc-windows-gnu/release/hemtt.exe /usr/share/target/hemtt.exe
