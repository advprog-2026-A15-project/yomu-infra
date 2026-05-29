#!/bin/bash
cd ~/yomu-app
sed -i 's/localhost:8085/service-clan:8085/g' seed-*.sh
sed -i 's/localhost:8082/service-learning:8082/g' seed-*.sh
sed -i 's/localhost:8084/service-forum:8084/g' seed-*.sh
sed -i 's/localhost:8081/service-auth:8081/g' seed-*.sh
docker run --rm --network yomu-app_default -v /home/ubuntu/yomu-app:/workspace -w /workspace ubuntu:22.04 bash -c "apt-get update && apt-get install -y curl python3 && bash ./seed-all.sh"
