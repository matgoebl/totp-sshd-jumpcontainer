FROM alpine
RUN apk add --no-cache openssh-server-pam google-authenticator openrc oath-toolkit-oathtool libqrencode-tools openssh-client ca-certificates

ARG JUMPUSER=jumper
ENV JUMPUSER=${JUMPUSER}

COPY sshd_config /user/etc/ssh/sshd_config
COPY sshd.pam /etc/pam.d/sshd.pam
COPY entry.sh /entry.sh
RUN ln -sf /etc/pam.d/sshd.pam /etc/pam.d/sshd && \
    adduser -D -u 10001 ${JUMPUSER} && \
    mkdir -p /user/.ssh/ /user/etc/ssh/ && \
    mv /etc/passwd /user/etc/passwd && ln -s /user/etc/passwd /etc/passwd && \
    mv /etc/shadow /user/etc/shadow && ln -s /user/etc/shadow /etc/shadow && \
    mv /etc/group  /user/etc/group  && ln -s /user/etc/group  /etc/group && \
    touch /user/.hushlogin && \
    touch /user/.google_authenticator && \
    chmod 0600 /user/.google_authenticator && \
    chmod 0700 /user/.ssh/ && \
    chown -R 10001 /user/ /etc/passwd /etc/shadow

ARG BUILDTAG=unknown
ENV BUILDTAG=${BUILDTAG}
RUN echo "${BUILDTAG}" > /user/build

WORKDIR /user
USER 10001
EXPOSE 2222
CMD ["/entry.sh"]

LABEL org.opencontainers.image.title="TOTP-enabled SSH daemon in a container used as DMZ jump-host" \
      org.opencontainers.image.source="https://github.com/matgoebl/totp-sshd-jumpcontainer" \
      org.opencontainers.image.authors="Matthias.Goebl@goebl.net" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="${BUILDTAG}"
