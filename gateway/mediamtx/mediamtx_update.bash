ARCH="$(uname -m)"
case "$ARCH" in 
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l) ARCH="arm" ;;
    *) echo "Unsupported architecture" ;;
esac

BASE_PATH="$HOME/.localrtsp/"
BINARY_PATH="$BASE_PATH"mediamtx
CONFIG_PATH="$BASE_PATH"mediamtx.yml
LICENSE_PATH="$BASE_PATH"LICENSE
URL_BASE="https://raw.githubusercontent.com/DurancOy/duranc_bootstrap/master/gateway/mediamtx/"
MD5_BINARY_URL="$URL_BASE"mediamtx_"$ARCH"_md5
MD5_CONFIG_URL="$URL_BASE"mediamtx_config_md5
DOWNLOAD_BINARY_URL="$URL_BASE"mediamtx_"$ARCH"
DOWNLOAD_CONF_URL="$URL_BASE"mediamtx.yml
LICENSE_URL="$URL_BASE"LICENSE

CURRENT_BINARY_MD5=""
REMOTE_BINARY_MD5="$(curl -s "$MD5_BINARY_URL")"
if [ -f "$BINARY_PATH" ]; then
    CURRENT_BINARY_MD5="$(md5sum "$BINARY_PATH" | awk '{ print $1 }')"
fi
if [ "$CURRENT_BINARY_MD5" == "$REMOTE_BINARY_MD5" ]; then
    echo "Mediamtx binary file is up to date"
else
    echo "Updating mediamtx binary file..."
    curl -s "$DOWNLOAD_BINARY_URL" -o "$BINARY_PATH"
    chmod +x "$BINARY_PATH"
fi

CURRENT_CONFIG_MD5=""
REMOTE_CONFIG_MD5="$(curl -s "$MD5_CONFIG_URL")"
if [ -f "$CONFIG_PATH" ]; then
    CURRENT_CONFIG_MD5="$(md5sum "$CONFIG_PATH" | awk '{ print $1 }')"
fi
if [ "$CURRENT_CONFIG_MD5" == "$REMOTE_CONFIG_MD5" ]; then
    echo "Mediamtx configuration file is up to date"
else
    echo "Updating mediamtx configuration file..."
    curl -s "$DOWNLOAD_CONF_URL" -o "$CONFIG_PATH"
    PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    sed -i "s/apiuser: PASSWORD_PLACEHOLDER/apiuser: $PASSWORD/g" $CONFIG_PATH
fi
echo "Updating mediamtx license file..."
curl -s "$LICENSE_URL" -o "$LICENSE_PATH"
echo "Mediamtx install end."
