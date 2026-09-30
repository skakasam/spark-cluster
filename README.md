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
  - `PGSQL_DIR`
  - `EVENTS_DIR`
  - `CATALOG_DIR`
  - `DATASETS_DIR`
  - `CHECKPOINTS_DIR`
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
docker exec -it spark-client /opt/spark/bin/spark-sql \
--conf spark.cores.max=4 \
--conf spark.executor.cores=1 \
--conf spark.executor.memory=1536m
```

```powershell
docker exec -it spark-client /opt/spark/bin/spark-sql `
--conf spark.cores.max=4 `
--conf spark.executor.cores=1 `
--conf spark.executor.memory=1536m
```

## Open spark-sql (SQL CLI) to interact with the cluster using ThriftServer and Beeline

Beeline provides a command-line interface to interact with the Spark ThriftServer using JDBC.

It formats the sql results in a tabular form for easier readability.

```bash
docker exec -it spark-client /opt/spark/bin/beeline -u jdbc:hive2://spark-client:10000
```

Note:

- The ThriftServer runs as a driver process inside the `spark-client` container (it is launched there via `docker exec`), so Beeline must connect to `spark-client:10000`, not `spark-master`.
- Ensure that the ThriftServer is running before attempting to connect with Beeline.
- `spark-submit --class ... HiveThriftServer2` requires a primary application resource; use `start-thriftserver.sh` instead, which handles this correctly and also picks up `spark.master` from `spark-defaults.conf`.
- Start the ThriftServer inside the `spark-client` container using the following command if necessary before connecting with Beeline:

```bash
# Start the ThriftServer inside the spark-client container using Bash
docker exec -it spark-client /opt/spark/sbin/start-thriftserver.sh \
--name "Hive Thrift Server"
```

```powershell
# Start the ThriftServer inside the spark-client container using PowerShell
docker exec -it spark-client /opt/spark/sbin/start-thriftserver.sh `
--name "Hive Thrift Server"
```

## Open pyspark (Python CLI) to interact with the cluster

```bash
docker exec -it spark-client /opt/spark/bin/pyspark \
--conf spark.cores.max=4 \
--conf spark.executor.cores=1 \
--conf spark.executor.memory=1536m
```

```powershell
docker exec -it spark-client /opt/spark/bin/pyspark `
--conf spark.cores.max=4 `
--conf spark.executor.cores=1 `
--conf spark.executor.memory=1536m
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
