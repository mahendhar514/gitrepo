@echo OFF
REM Create a link for docker config
REM mklink /H C:/Users/%USERNAME%/.docker/auth.json C:/Users/%USERNAME%/.docker/config.json

echo c6356d49-4f26-43f0-890c-75aceb6fc3ca > %USERPROFILE%/.docker/cred.txt
more %USERPROFILE%/.docker/cred.txt | docker login --username durancai --password-stdin

REM Create docker volumes for persistent storage
docker volume create edge-ai-gw-files
docker volume create edge-ai-motion-files

REM Download docker compose file
curl -o C:/Users/%USERNAME%/docker-compose-gateway-windows.yml https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/docker-compose-gateway-windows.yml

REM Build docker containers
docker-compose -f C:/Users/%USERNAME%/docker-compose-gateway-windows.yml up -d

REM Show running container
docker ps -a

@echo ON
