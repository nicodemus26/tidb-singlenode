FROM debian:stretch-slim
# Official installation documents here: https://github.com/pingcap/docs/blob/master/op-guide/binary-deployment.md#single-node-cluster-deployment

ENV BINARY_TARGET=linux-amd64 \
    TIDB_VERSION=v1.0.1 \
    TIDB_TARBALL_SHA256SUM=b9b3a8a100ffddb33a65b7f319f542957accadd8ed93f1c0e4569294b77e4418 \
    TIDB_PACKAGE_ROOT=/opt/tidb \
    TIDB_SINGLENODE_SCRIPTS=/opt/tidb/bin/tidb-singlenode-scripts \
    DATA_DIR=/var/tidb

ENV PATH=$PATH:$TIDB_PACKAGE_ROOT/bin:$TIDB_SINGLENODE_SCRIPTS \
    PD_DATA_DIR=$DATA_DIR/pd \
    TIKV_DATA_DIR=$DATA_DIR/tikv \
    TIDB_TARBALL_URL=https://download.pingcap.org/tidb-$TIDB_VERSION-$BINARY_TARGET.tar.gz \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_TCP_PORT=4000

RUN apt-get update \
    && apt-get install -y wget mysql-client \
    && echo "Downloading $TIDB_TARBALL_URL..." \
    && wget $TIDB_TARBALL_URL -O /tmp/tidb.tar.gz --progress=dot:giga \
    && ls -la /tmp/tidb.tar.gz \
    && echo "Verifying tarball's sha256sum..." \
    && bash -ex -c "sha256sum /tmp/tidb.tar.gz && sha256sum /tmp/tidb.tar.gz | grep -c $TIDB_TARBALL_SHA256SUM" \
    && mkdir -p $TIDB_PACKAGE_ROOT $DATA_DIR $PD_DATA_DIR $TIKV_DATA_DIR \
    && tar -xzvf /tmp/tidb.tar.gz --directory=$TIDB_PACKAGE_ROOT \
    && ln -sf $TIDB_PACKAGE_ROOT/*/bin $TIDB_PACKAGE_ROOT/bin \
    && echo "Cleaning up for a smallish image layer." \
    && rm -f /tmp/tidb.tar.gz \
    && apt-get remove -y --purge wget \
    && apt-get autoremove -y --purge \
    && apt-get clean all

ADD tidb-singlenode-scripts $TIDB_SINGLENODE_SCRIPTS
EXPOSE 4000
CMD ["start_tidb_stack.sh"]
