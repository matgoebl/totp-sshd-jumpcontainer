FROM alpine
RUN apk add --no-cache openssh-server-pam google-authenticator openrc oath-toolkit-oathtool libqrencode-tools openssh-client ca-certificates

ARG JUMPUSER=jumper
ENV JUMPUSER=${JUMPUSER}

RUN adduser -D -u 10001 ${JUMPUSER} && \
    touch /home/${JUMPUSER}/.hushlogin && \
    touch /home/${JUMPUSER}/.google_authenticator && \
    chmod 0600 /home/${JUMPUSER}/.google_authenticator && \
    chown -R ${JUMPUSER} /home/${JUMPUSER}/

COPY sshd_config /etc/ssh/sshd_config
COPY sshd.pam /etc/pam.d/sshd.pam
COPY entry.sh /entry.sh
RUN ln -sf /etc/pam.d/sshd.pam /etc/pam.d/sshd

WORKDIR /tmp
EXPOSE 22
CMD ["/entry.sh"]

LABEL org.opencontainers.image.title="TOTP-enabled SSH daemon in a container used as DMZ jump-host" \
      org.opencontainers.image.source="https://github.com/matgoebl/totp-sshd-jumpcontainer" \
      org.opencontainers.image.authors="Matthias.Goebl@goebl.net" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="${BUILDTAG}"
