#!/bin/sh
set -eu
IFS=$'\n\t'

if [ -z "${USER:-}" ]; then
    echo "\$USER is missing. exiting."
    exit 1
fi

if [ -z "${PASS:-}" ]; then
    echo "\$PASS is not set. generating it."
    export PASS="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c ${1:-16})"
fi

if [ -z "${TOTP:-}" ]; then
    echo "\$TOTP is not set. generating it."
    export TOTP="$(head /dev/urandom | tr -dc A-Z2-7 | head -c ${1:-16})"
fi

HOST="${HOST:-totp-sshd-jumpcontainer}"
QRURL="otpauth://totp/$HOST:$USER%20$PASS%20`date +%Y-%m-%d`?secret=$TOTP&issuer=$HOST"
echo "USER: $USER"
echo "PASS: $PASS"
echo "TOTP: $TOTP"
echo "First token: `oathtool --base32 $TOTP --totp`"
echo "QR code URL: $QRURL"
qrencode -t ANSI256 "$QRURL"

/etc/init.d/sshd checkconfig
echo "$USER:$PASS" | chpasswd

cat <<__X__ >/home/$USER/.google_authenticator
$TOTP
" RATE_LIMIT 3 30
" DISALLOW_REUSE
" TOTP_AUTH
__X__

exec /usr/sbin/sshd.pam -D -e
