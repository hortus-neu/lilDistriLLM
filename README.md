# lilDistriLLM

Distributed LLM Inference and Data Processing Platform

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Kubernetes-orange)

---

# Project Overview
This project aims to utilize Hadoop and Spark for large-scale data processing, write high-performance middleware and apis with RustGo, conduct container orchestration and deployment with Kubernetes, and integrate LLM inference optimization techniques (such as model quantization). Build LLM-based applications using dynamic batch processing and LangChain, etc

---

# Tech Stack


---

# Architecture
```
The user requests => the K8s Ingress => Rust gateway => Spark to process => the LLM inference cluster => result return
```

---

# Quick Start

```
# git clone
git clone https://github.com/hortus-neu/DistriLLM.git
cd DistriLLM

# run dev
make dev-setup

# deploy basical set-ups
make deploy-local
```

---

# System Overview

This project builds a distributed LLM inference and data processing platform
combining Spark, Kubernetes, Rust, and LangChain.

- **Docker Compose** for local orchestration (Spark, Redis, MinIO)
- **Kubernetes** for cluster deployment (API Gateway, Inference Service)
- **Ports**: Spark UI (8080), Redis (6379), MinIO (9000/9001), API Gateway (8080→80)
- **Features**: scalable inference, real-time data streaming, containerized services


- [中文版本](docs/architecture/system-design.zh.md)
- [English Version](docs/architecture/system-design.en.md)



---

# Structure

```
.
├── config
├── docker-compose.yml # Local development stack (Spark, Redis, MinIO, etc.)
├── docs # Project documentation
│   ├── api # API reference or design docs
│   └── architecture # System architecture diagrams and technical specs
├── k8s # Kubernetes deployment configurations
│   └── manifests # YAML manifests for Deployments, Services, etc.
├── LICENSE
├── Makefile # Build and deployment automation commands
├── README.md # Project introduction and setup guide
├── requirements.txt # Python dependencies for the inference and LangChain modules
├── scripts # Utility scripts for setup, testing, or maintenance
└── src # Source code of all core services
    ├── api-gateway # Rust-based API Gateway (handles routing and orchestration)
    ├── inference-engine # FastAPI + PyTorch inference service
    ├── langchain-app # LangChain logic for agent reasoning and memory
    └── spark-jobs # Distributed data processing jobs for Spark
```
