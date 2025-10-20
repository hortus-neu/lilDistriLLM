# 设计文档
---
# 目录

- [设计文档](#设计文档)
- [目录](#目录)
- [0. 配置和依赖](#0-配置和依赖)
  - [0.1 `docker-compose` 文件](#01-docker-compose-文件)
  - [0.2 为什么有的在 `docker-compose.yml`，有的单独写 `.yaml`？](#02-为什么有的在-docker-composeyml有的单独写-yaml)
  - [0.3 端口全览](#03-端口全览)
  - [0.4  层级关系图](#04--层级关系图)
---

# 0. 配置和依赖

## 0.1 `docker-compose` 文件

这个文件定义了一个包含四个服务的集群：

1. **Spark Master（主节点）**
2. **Spark Worker（工作节点）**
3. **Redis（内存数据存储）**
4. **MinIO（对象存储）**

每个服务都使用一个镜像（image）来创建容器。

- **spark-master** 和 **spark-worker** 都使用 `bitnami/spark:latest` 镜像。
  通过环境变量设置 Spark 的运行模式（master 或 worker），并关闭认证与加密以简化开发环境。
  `spark-worker` 通过 `SPARK_MASTER_URL` 指定连接到 master 节点，并通过 `depends_on` 确保 master 先启动。

- **redis** 使用 `redis:alpine` 镜像，暴露默认端口 6379。

- **minio** 使用 `minio/minio` 镜像，暴露端口 9000（API）和 9001（控制台），并设置默认的管理员账号和密码。

当在项目根目录运行：

```bash
docker-compose up
````

它会自动执行以下步骤：

1. 启动内部虚拟网络
2. 拉取所需镜像（Spark, Redis, MinIO）
3. 按依赖顺序启动容器

   * 启动 `spark-master`
   * 启动 `spark-worker`
   * 启动 Redis 和 MinIO
4. 建立容器间互联
5. 形成一个 **小型分布式计算环境**

启动后访问入口

| 访问点                                            | 功能说明          |
| :--------------------------------------------- | :------------ |
| [http://localhost:8080](http://localhost:8080) | Spark Web 控制台 |
| [http://localhost:9001](http://localhost:9001) | MinIO 管理控制台   |
| Redis 客户端连接 `localhost:6379`                   | 查看缓存数据        |


## 0.2 为什么有的在 `docker-compose.yml`，有的单独写 `.yaml`？

这其实是两种不同层级的编排系统：

| 层级                  | 文件                                | 用途        | 范围   |
| :------------------ | :-------------------------------- | :-------- | :--- |
| 🐳 Docker Compose   | `docker-compose.yml`              | 本地开发、测试   | 单台机器 |
| ☸️ Kubernetes (K8s) | `deployment.yaml`, `service.yaml` | 集群部署、生产环境 | 多台机器 |


🐳 Docker Compose 适合：

* 本地快速起环境
* 一键启动多个服务（`docker-compose up`）
* 模拟分布式部署（Spark、Redis、MinIO）

Compose 就像是一个 **迷你版 Kubernetes**，
可以在开发机上模拟集群行为。



☸️ Kubernetes 适合：

* 生产环境 / 云端集群
* 自动扩容 / 负载均衡
* 服务隔离与生命周期管理

在 Kubernetes 中，每个组件单独定义：

* **Deployment**：定义运行的副本数量、镜像
* **Service**：定义端口暴露和访问规则
* **ConfigMap / Secret**：配置与密钥
* **Ingress**：外部访问入口


## 0.3 端口全览

| 模块                       | 环境           | 外部访问端口            | 容器内部端口            | 用途                 |
| :----------------------- | :----------- | :---------------- | :---------------- | :----------------- |
| **Spark Master**         | Docker       | 8080              | 8080              | Web 控制台            |
|                          | Docker       | 7077              | 7077              | Worker 与 Master 通信 |
| **Spark Worker**         | Docker       | -                 | -                 | 不暴露外部端口            |
| **Redis**                | Docker / K8s | 6379              | 6379              | 缓存数据库              |
| **MinIO**                | Docker       | 9000              | 9000              | 对象存储 API           |
|                          | Docker       | 9001              | 9001              | 管理界面               |
| **API Gateway (Rust)**   | Docker       | 8080              | 8080              | 服务网关               |
|                          | K8s          | 80 (Service.port) | 8080 (targetPort) | 集群入口               |
| **Inference (Python)**   | Docker / K8s | 3000              | 3000              | 模型推理               |
| **Prometheus / Grafana** | K8s          | 9090 / 3000       | 9090 / 3000       | 监控系统 UI            |

## 0.4  层级关系图

```
🧠 应用层（FastAPI / Rust / PyTorch / Spark）
   ↓
🐳 容器层（Docker Container）
   ↓
☸️ Pod 层（Kubernetes 将容器打包在一起）
   ↓
🌍 节点层（Node：实际运行的机器）
   ↓
🖥️ 集群层（Kubernetes Cluster）

```




