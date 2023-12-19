#!/bin/sh
set -eu
IFS=$'\n\t'

: "${JUMPUSER:=jumper}"
: "${JUMPHOST:=totp-sshd-jumpcontainer}"

if [ -z "${JUMPPASS:-}" ]; then
    echo "\$JUMPPASS is not set. generating it."
    JUMPPASS="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c ${1:-16})"
fi

if [ -z "${JUMPTOTP:-}" ]; then
    echo "\$JUMPTOTP is not set. generating it."
    JUMPTOTP="$(head /dev/urandom | tr -dc A-Z2-7 | head -c ${1:-16})"
fi

QRURL="otpauth://totp/$JUMPHOST:$JUMPUSER%20$JUMPPASS%20`date +%Y-%m-%d`?secret=$JUMPTOTP&issuer=$JUMPHOST"
echo "JUMPUSER: $JUMPUSER"
echo "JUMPPASS: $JUMPPASS"
echo "JUMPTOTP: $JUMPTOTP"
if [ -n "${JUMPKEY:-}" ]; then
 mkdir -p /home/$JUMPUSER/.ssh/
 echo "$JUMPKEY" > /home/$JUMPUSER/.ssh/authorized_keys
 chmod -R go= /home/$JUMPUSER/.ssh/
 chown -R $JUMPUSER /home/$JUMPUSER/.ssh/
 echo "JUMPKEY: $JUMPKEY"
fi
echo "First TOTP code: `oathtool --base32 $JUMPTOTP --totp`"
echo "QR code URL: $QRURL"
qrencode -t UTF8 "$QRURL"

/etc/init.d/sshd checkconfig
echo "$JUMPUSER:$JUMPPASS" | chpasswd

cat <<__X__ >/home/$JUMPUSER/.google_authenticator
$JUMPTOTP
" RATE_LIMIT 3 30
" DISALLOW_REUSE
" TOTP_AUTH
__X__

exec /usr/sbin/sshd.pam -D -e
