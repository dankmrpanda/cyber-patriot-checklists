TLSRSACertificateFile /etc/ssl/certs/proftpdcertificate.pem
TLSRSACertificateKeyFile /etc/ssl/private/proftpdserverkey.pem
TLSEngine on
TLSLog /var/log/proftpd/tls.log
TLSProtocol TLSv1.2
TLSRequired on
TLSOptions NoCertRequest EnableDiags NoSessionReuseRequired
TLSVerifyClient off
Include /etc/proftpd/tls.conf
