# Novus PySpark Multi-Node Cluster

This repository contains the configuration and instructions to set up a multi-node Apache Spark cluster using Docker Compose. The cluster includes a Spark client, Spark master, Spark worker nodes, and a PostgreSQL database for the metastore. This cluster uses the apache/spark:4.2.0 as the base image and PostgreSQL as the metastore database for Delta Lake integration.

Please follow the instructions below to build, start, and interact with the cluster. Copy `.env.example` to `.env` in the root directory to configure environment variables for PostgreSQL credentials, volume host paths, port mappings, image tags, and container resource limits.

## Environment Configuration

Before launching the cluster, create a `.env` file from the provided example template:

```bash
cp .env.example .env
```

Key environment variables in `.env`:

- **Credentials & Database**:
  - `POSTGRES_DB`
  - `POSTGRES_USER`
  - `POSTGRES_PASSWORD`
- **Volume Locations**:
  - `PROJECTS_DIR`
  - `PGSQL_DATA_DIR`
  - `CLUSTER_DATA_DIR`
  - `CLUSTER_EVENTS_DIR`
  - `CLUSTER_WAREHOUSE_DIR`
- **Port Mappings**:
  - `POSTGRES_PORT`
  - `SPARK_MASTER_WEBUI_PORT`
  - `SPARK_MASTER_PORT`
  - `SPARK_HISTORY_UI_PORT`
  - etc.
- **Resource Limits**:
  - `POSTGRES_CPUS`
  - `POSTGRES_MEMORY`
  - `SPARK_MASTER_CPUS`
  - `SPARK_WORKER_CPUS`
  - `SPARK_WORKER_MEMORY_LIMIT`
  - etc.
- **Image Tags & Build Args**:
  - `POSTGRES_IMAGE`
  - `SPARK_IMAGE`
  - `HADOOP_VERSION`

## Build the cluster

```bash
docker compose down
docker compose build
docker compose up -d
```

## Start the cluster

```bash
docker compose up -d
```

## Stop the cluster

```bash
docker compose down
```

## Other Useful Cluster Commands

```bash
docker compose ps
docker compose logs -f
```

## Submit a spark job to the cluster

```bash
docker exec spark-client /opt/spark/bin/spark-submit /opt/spark/work-dir/projects/demo/src/demo_job.py
```

## Open spark-sql (SQL CLI) to interact with the cluster

```bash
docker exec -it spark-client /opt/spark/bin/spark-sql
```

## Open spark-sql (SQL CLI) to interact with the cluster using ThriftServer and Beeline

Beeline provides a command-line interface to interact with the Spark ThriftServer using JDBC.

It formats the sql results in a tabular form for easier readability.

```bash
docker exec -it spark-client /opt/spark/bin/beeline -u jdbc:hive2://spark-master:10000
```

Note:

- Ensure that the ThriftServer is running on the Spark master before attempting to connect with Beeline.
- Start the ThriftServer on the Spark master using the following command if necessary before connecting with Beeline:

```bash
# Start the ThriftServer on the Spark master using Bash
docker exec -it spark-client /opt/spark/bin/spark-submit \
--class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
--name "Hive Thrift Server"
```

```powershell
# Start the ThriftServer on the Spark master using PowerShell
docker exec -it spark-client /opt/spark/bin/spark-submit `
--class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 `
--name "Hive Thrift Server"
```

## Open pyspark (Python CLI) to interact with the cluster

```bash
docker exec -it spark-client /opt/spark/bin/pyspark
```

## Open bash (Bash Shell) to interact with the cluster

```bash
docker exec -it spark-client /bin/bash
```

## Execute a query on the PgSQL database

```bash
docker exec -it postgres-db psql -U ${POSTGRES_USER:-pgsql_user} -d ${POSTGRES_DB:-metastore_db_name} -c "\dt"
docker exec -it postgres-db psql -U ${POSTGRES_USER:-pgsql_user} -d ${POSTGRES_DB:-metastore_db_name}
```
