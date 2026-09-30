################################################################################
# Set base image for the Spark environment
################################################################################
FROM apache/spark:4.2.0-scala2.13-java21-python3-ubuntu

################################################################################
# Switch to root to install packages
################################################################################
USER root

################################################################################
# Install system dependencies (curl is required by the spark-master healthcheck)
################################################################################
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

################################################################################
# Install Python dependencies
################################################################################
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/usr/bin/python3
COPY ./conf/python/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

################################################################################
# Set Spark classpath for app-provided jars (Delta, Postgres JDBC, etc.)
# No separate Hadoop install: Spark already bundles hadoop-client-api/runtime
# and JNI codec jars (snappy/lz4/zstd), which cover local-disk standalone mode.
################################################################################
ENV APP_JARS_PATH="/opt/spark/app-jars/*"
ENV SPARK_DIST_CLASSPATH="$APP_JARS_PATH"

################################################################################
# Create JVM home directory
################################################################################
RUN mkdir -p /opt/spark/work-dir/.home
RUN chown -R spark:spark /opt/spark/work-dir/.home

################################################################################
# Switch back to the default spark user
################################################################################
USER spark
