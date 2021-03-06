#
# Dockerfile
#
# @author zhibiao.pan@bitmain.com, yihao.peng@bitmain.com
# @copyright btc.com
# @since 2016-08-01
#
#
FROM phusion/baseimage:0.9.22
MAINTAINER PanZhibiao <zhibiao.pan@bitmain.com>

ENV HOME /root
ENV TERM xterm
CMD ["/sbin/my_init"]

# use aliyun source
ADD sources-aliyun.com.list /etc/apt/sources.list

# build bitcoind and clean
# Docker generates a new layer for each RUN command, so the download and cleanup must in a single RUN command.
RUN  apt-get update \
  && apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 \
  && apt-get install -y libboost-all-dev libzmq3-dev curl wget net-tools \
  && mkdir ~/source \
  && cd ~/source \
  && wget https://github.com/bitcoin/bitcoin/archive/v0.15.1.tar.gz \
  && tar zxf v0.15.1.tar.gz \
  && cd bitcoin-0.15.1 \
  && ./autogen.sh \
  && ./configure --disable-wallet --disable-tests \
  && make -j$(nproc) \
  && make install \
  && rm -rf ~/source \
  && apt-get purge -y libboost-all-dev \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# mkdir bitcoind data dir
RUN mkdir -p /root/.bitcoin
RUN mkdir -p /root/scripts

# scripts
ADD opsgenie-monitor-bitcoind.sh   /root/scripts/opsgenie-monitor-bitcoind.sh

# crontab shell
ADD crontab.txt /etc/cron.d/bitcoind

# logrotate
ADD logrotate-bitcoind /etc/logrotate.d/bitcoind

#
# services
#
# service for mainnet
RUN mkdir    /etc/service/bitcoind
ADD run      /etc/service/bitcoind/run
RUN chmod +x /etc/service/bitcoind/run
# service for testnet3
#RUN mkdir        /etc/service/bitcoind_testnet3
#ADD run_testnet3 /etc/service/bitcoind_testnet3/run
#RUN chmod +x     /etc/service/bitcoind_testnet3/run
