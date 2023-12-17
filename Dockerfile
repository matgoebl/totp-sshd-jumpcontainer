FROM alpine
RUN apk add --no-cache openssh-server-pam google-authenticator openrc oath-toolkit-oathtool libqrencode-tools

ARG USER=jumper
ENV USER=${USER}

RUN adduser -D -u 10001 ${USER} && \
    touch /home/${USER}/.hushlogin && \
    touch /home/${USER}/.google_authenticator && \
    chmod 0600 /home/${USER}/.google_authenticator && \
    chown -R ${USER} /home/${USER}/

COPY sshd_config /etc/ssh/sshd_config
COPY sshd.pam /etc/pam.d/sshd.pam
COPY entry.sh /entry.sh
RUN ln -sf /etc/pam.d/sshd.pam /etc/pam.d/sshd

WORKDIR /tmp
EXPOSE 22
CMD ["/entry.sh"]
