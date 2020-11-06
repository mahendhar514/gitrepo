REM Create a link for docker config
mklink /H C:/Users/%USERNAME%/.docker/auth.json C:/Users/%USERNAME%/.docker/config.json

REM Create docker volumes for persistent storage
docker volume create edge-ai-gw-files
docker volume create edge-ai-motion-files

REM Download docker compose file
curl -o C:/Users/%USERNAME%/docker-compose-gateway-windows.yml https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/docker-compose-gateway-windows.yml

REM Build docker containers
docker-compose -f C:/Users/%USERNAME%/docker-compose-gateway-windows.yml up -d

REM Show running container
cls
docker ps -a
