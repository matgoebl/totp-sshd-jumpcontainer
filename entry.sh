#!/bin/sh
set -eu
IFS=$'\n\t'

ssh-keygen -A -f /user

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

# This does not work: "chpasswd: permission denied (are you root?)"
# echo "$JUMPUSER:$JUMPPASS" | chpasswd
# This is a replacement:

(cat /user/etc/shadow | grep -v "^$JUMPUSER:"; echo "$JUMPUSER:`mkpasswd \"$JUMPPASS\"`:19710:0:99999:7:::") >/user/etc/shadow.new; cat /user/etc/shadow.new > /user/etc/shadow
(cat /user/etc/passwd | grep -v "^[^:]*:[^:]*:10001:"; echo "$JUMPUSER:x:10001:10001:Linux User,,,:/user:/bin/ash") >/user/etc/passwd.new; cat /user/etc/passwd.new > /user/etc/passwd
(cat /user/etc/group  | grep -v "^[^:]*:[^:]*:10001:"; echo "$JUMPUSER:x:10001:") >/user/etc/group.new; cat /user/etc/group.new > /user/etc/group

echo ---
echo "BUILD: `cat /user/build`"
echo "JUMPUSER: $JUMPUSER"
echo "JUMPPASS: $JUMPPASS"
echo "JUMPTOTP: $JUMPTOTP"
if [ -n "${JUMPKEY:-}" ]; then
 mkdir -p /user/.ssh/
 echo "$JUMPKEY" > /user/.ssh/authorized_keys
 chmod -R go= /user/.ssh/
 chown -R $JUMPUSER /user/.ssh/
 echo "JUMPKEY: $JUMPKEY"
fi
echo "First TOTP code: `oathtool --base32 $JUMPTOTP --totp`"
QRURL="otpauth://totp/$JUMPHOST:$JUMPUSER%20$JUMPPASS%20`date +%Y-%m-%d`?secret=$JUMPTOTP&issuer=$JUMPHOST"
echo "QR code URL: $QRURL"
qrencode -t UTF8 "$QRURL"

cat <<__X__ >/user/.google_authenticator
$JUMPTOTP
" RATE_LIMIT 3 30
" DISALLOW_REUSE
" TOTP_AUTH
__X__

exec /usr/sbin/sshd.pam -f /user/etc/ssh/sshd_config -D -e
