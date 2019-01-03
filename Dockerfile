FROM debian:jessie

RUN mkdir -p /app && \
    apt update && \
    apt install -y g++ make cmake cmake-curses-gui python3 gfortran \
                   flex bison git curl

COPY . /app
WORKDIR /app

# Install maxent

RUN git clone https://github.com/lzhang10/maxent.git && \
    cd maxent && \
    ./configure && make && make install

# avoid dependency hell and install it now
RUN apt install -y zlib1g-dev libltdl-dev libpcre3-dev \
    libpcrecpp0 libboost-all-dev libtbb-dev 

# Install trtok

RUN curl --output "quex.tar.gz" -L https://sourceforge.net/projects/quex/files/HISTORY/0.63/quex-0.63.1.tar.gz/download && \
    tar xvf "quex.tar.gz"

ARG QUEX_PATH=/app/quex-0.63.1

RUN mkdir -p build && cd build && \
    cmake ../src -DCMAKE_BUILD_TYPE=Release

RUN cd /app/build && make -j 4 && make install

ENV PATH="/root/trtok/:${PATH}"