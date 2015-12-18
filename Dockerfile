FROM ubuntu:15.04

ENV CABALVER 1.22
ENV GHCVER 7.10.1

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:hvr/ghc && \
    apt-get update && \
    apt-get install -y cabal-install-$CABALVER ghc-$GHCVER && \
    . /etc/environment && \
    echo "PATH=/opt/ghc/$GHCVER/bin:/opt/cabal/$CABALVER/bin:$PATH" > /etc/environment

ENV PATH=/opt/ghc/$GHCVER/bin:/opt/cabal/$CABALVER/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD http://www.stackage.org/nightly/cabal.config .
RUN cabal update && \
    cabal install aeson exceptions lens mtl network network-uri random text stm

ADD https://github.com/commercialhaskell/stack/releases/download/v0.1.6.0/stack-0.1.6.0-linux-x86_64.tar.gz .
RUN tar -C /usr/bin/ -xf stack-0.1.6.0-linux-x86_64.tar.gz --strip=1 stack-0.1.6.0-linux-x86_64/stack && \
    stack --no-system-ghc setup && \
    cd /tmp && \
    stack new --resolver=nightly stack-nightly && \
    cd stack-nightly && \
    stack install aeson exceptions lens mtl network network-uri random text stm && \
    cd && \
    rm -rf /tmp/stack-nightly

RUN apt-get clean && \
    mv cabal.config /var/cache/cabal.config && \
    rm -rf /root/.cabal/packages /root/.cabal/logs \
        /var/lib/apt/lists/* /tmp/* /var/tmp/*
