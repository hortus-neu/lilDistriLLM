# System Design Document
---
# Table of Contents

- [System Design Document](#system-design-document)
- [Table of Contents](#table-of-contents)
- [0. Configuration and Dependencies](#0-configuration-and-dependencies)
  - [0.1 `docker-compose` File](#01-docker-compose-file)
  - [0.2 Why some are in `docker-compose.yml` while others are in separate `.yaml` files?](#02-why-some-are-in-docker-composeyml-while-others-are-in-separate-yaml-files)
  - [0.3 Port Overview](#03-port-overview)
  - [0.4 Layer Relationship Diagram](#04-layer-relationship-diagram)

---

# 0. Configuration and Dependencies

## 0.1 `docker-compose` File

This file defines a cluster containing four services:

1. **Spark Master (main node)**
2. **Spark Worker (worker node)**
3. **Redis (in-memory data storage)**
4. **MinIO (object storage)**

Each service is created from a Docker image.

- **spark-master** and **spark-worker** both use the `bitnami/spark:latest` image.
  Environment variables configure Spark’s running mode (master or worker), and authentication/encryption are disabled for simplicity in development.
  `spark-worker` connects to the master node via `SPARK_MASTER_URL`, and `depends_on` ensures the master starts first.

- **redis** uses the `redis:alpine` image and exposes the default port `6379`.

- **minio** uses the `minio/minio` image, exposing port `9000` (API) and `9001` (console), and sets default admin credentials via environment variables.

When you run the following command in the project root directory:

```bash
docker-compose up
````

It automatically performs these steps:

1. Creates an internal virtual network
2. Pulls the required images (Spark, Redis, MinIO)
3. Starts containers in dependency order

   * Start `spark-master`
   * Start `spark-worker`
   * Start Redis and MinIO
4. Establish container interconnections
5. Form a **small distributed computing environment**

Access Points After Startup

| Endpoint                                       | Description              |
| :--------------------------------------------- | :----------------------- |
| [http://localhost:8080](http://localhost:8080) | Spark Web UI             |
| [http://localhost:9001](http://localhost:9001) | MinIO Management Console |
| Redis client connects to `localhost:6379`      | View cached data         |



## 0.2 Why some are in `docker-compose.yml` while others are in separate `.yaml` files?

These represent two different levels of orchestration systems:

| Layer               | File                              | Purpose                         | Scope                 |
| :------------------ | :-------------------------------- | :------------------------------ | :-------------------- |
| 🐳 Docker Compose   | `docker-compose.yml`              | Local development and testing   | Single machine        |
| ☸️ Kubernetes (K8s) | `deployment.yaml`, `service.yaml` | Cluster deployment / production | Multi-machine cluster |



🐳 **Docker Compose is suitable for:**

* Quickly booting up local environments
* One-command startup for multiple services (`docker-compose up`)
* Simulating distributed deployments (Spark, Redis, MinIO)

Compose works like a **mini version of Kubernetes**,
allowing you to simulate a cluster locally during development.



☸️ **Kubernetes is suitable for:**

* Production environments / cloud clusters
* Auto-scaling / load balancing
* Service isolation and lifecycle management

In Kubernetes, each component is defined separately:

* **Deployment**: defines number of replicas and container images
* **Service**: defines port exposure and access rules
* **ConfigMap / Secret**: defines configuration and credentials
* **Ingress**: defines external access entry



## 0.3 Port Overview

| Module                   | Environment  | External Port     | Internal Container Port | Description                   |
| :----------------------- | :----------- | :---------------- | :---------------------- | :---------------------------- |
| **Spark Master**         | Docker       | 8080              | 8080                    | Web UI                        |
|                          | Docker       | 7077              | 7077                    | Worker ↔ Master communication |
| **Spark Worker**         | Docker       | -                 | -                       | No external port exposed      |
| **Redis**                | Docker / K8s | 6379              | 6379                    | Cache database                |
| **MinIO**                | Docker       | 9000              | 9000                    | Object storage API            |
|                          | Docker       | 9001              | 9001                    | Management console            |
| **API Gateway (Rust)**   | Docker       | 8080              | 8080                    | Gateway service               |
|                          | K8s          | 80 (Service.port) | 8080 (targetPort)       | Cluster entry point           |
| **Inference (Python)**   | Docker / K8s | 3000              | 3000                    | Model inference               |
| **Prometheus / Grafana** | K8s          | 9090 / 3000       | 9090 / 3000             | Monitoring system UI          |



## 0.4 Layer Relationship Diagram

```
🧠 Application Layer (FastAPI / Rust / PyTorch / Spark)
   ↓
🐳 Container Layer (Docker Container)
   ↓
☸️ Pod Layer (Kubernetes groups containers)
   ↓
🌍 Node Layer (Node: physical machine)
   ↓
🖥️ Cluster Layer (Kubernetes Cluster)
```



