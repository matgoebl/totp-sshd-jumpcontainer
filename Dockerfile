FROM alpine
RUN apk add --no-cache openssh-server-pam google-authenticator openrc oath-toolkit-oathtool libqrencode-tools

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
