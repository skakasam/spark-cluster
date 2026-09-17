FROM apache/spark:4.2.0-scala2.13-java21-python3-ubuntu

# Switch to root to install packages
USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tar \
    curl \
    zlib1g-dev \
    libssl-dev \
    liblz4-dev \
    libzstd-dev \
    libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Hadoop and configure native libraries
ARG HADOOP_VERSION=3.4.2
ENV HADOOP_VERSION=${HADOOP_VERSION}
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV LD_LIBRARY_PATH="$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH"
ENV HADOOP_OPTS="$HADOOP_OPTS -Djava.library.path=$HADOOP_HOME/lib/native"
ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

RUN curl -sL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar -xz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm -rf ${HADOOP_HOME}/share/doc

# Install python dependencies
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/usr/bin/python3

COPY ./conf/python/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Set environment variables for Spark classpath in standalone mode (no YARN/HDFS)
# Keeping only Hadoop Common, MapReduce, client JARs in the classpath
ENV APP_JARS_PATH="/opt/spark/app-jars/*"
ENV MAPR_JARS_PATH="/opt/hadoop/share/hadoop/mapreduce/*"
ENV HADOOP_JARS_PATH="/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*"
ENV SPARK_DIST_CLASSPATH="$APP_JARS_PATH:$MAPR_JARS_PATH:$HADOOP_JARS_PATH"

# HDFS and YARN trees are excluded to keep the classpath lean and avoid classloader conflicts.
#ENV HDFS_JARS_PATH="/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*"
#ENV YARN_JARS_PATH="/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/*"
#ENV SPARK_DIST_CLASSPATH="$APP_JARS_PATH:$MAPR_JARS_PATH:$HDFS_JARS_PATH:$YARN_JARS_PATH:$HADOOP_JARS_PATH"

# Switch back to the default spark user
USER spark
