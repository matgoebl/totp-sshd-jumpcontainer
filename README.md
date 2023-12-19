# totp-sshd-jumpcontainer
TOTP-enabled SSH daemon in a container used as DMZ jump-host

Currently it's quite simple: Only one user, one password, one TOTP secret. No user database.
The password and secret can be passed via environment. Otherwise credentials are created and
listed on stdout - so keep your logs secret.

It runs as non-root user 10001, so it it satisfies
[kubesec's requirement RUNASUSER>10000](https://kubesec.io/basics/containers-securitycontext-runasuser/)
and allows to maintain a [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
level of [restricted](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted).

It's based on https://wiki.alpinelinux.org/wiki/Setting_up_a_SSH_server
and https://wiki.alpinelinux.org/wiki/HOWTO_OpenSSH_2FA_with_password_and_Google_Authenticator.
