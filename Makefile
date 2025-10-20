.PHONY: help build push deploy test clean

help:
	@echo "Available commands:"
	@echo "  build-api-gateway   - Build the Rust API gateway"
	@echo "  build-inference     - Build the Python inference service"
	@echo "  up                  - Start local development stack (docker-compose up)"
	@echo "  down                - Stop local development stack (docker-compose down)"
	@echo "  deploy-k8s          - Deploy to Kubernetes"
	@echo "  test                - Run tests"

build-api-gateway:
	cd src/api-gateway && cargo build --release

build-inference:
	docker build -t distrillm/inference:latest -f Dockerfile.inference .

up:
	docker-compose up -d

down:
	docker-compose down

deploy-k8s:
	kubectl apply -f k8s/manifests/

test:
	cd src/api-gateway && cargo test
	# TODO: Add tests for other components

clean:
	cd src/api-gateway && cargo clean
