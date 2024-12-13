#This script will automate the apache2 security configuration
# Configuration File - Apache Server Configs
# https://httpd.apache.org/docs/current/

# Sets the top of the directory tree under which the server's configuration,
# error, and log files are kept.
# Do not add a slash at the end of the directory path.
# If you point ServerRoot at a non-local disk, be sure to specify a local disk
# on the Mutex directive, if file-based mutexes are used.
# If you wish to share the same ServerRoot for multiple httpd daemons, you will
# need to change at least PidFile.
# https://httpd.apache.org/docs/current/mod/core.html#serverroot
ServerRoot "/usr/local/apache2"

# Loads Dynamic Shared Object (DSO), httpd modules.
# https://httpd.apache.org/docs/current/mod/mod_so.html#loadmodule
LoadModule mpm_event_module modules/mod_mpm_event.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule include_module modules/mod_include.so
LoadModule filter_module modules/mod_filter.so
LoadModule deflate_module modules/mod_deflate.so
LoadModule mime_module modules/mod_mime.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule env_module modules/mod_env.so
LoadModule expires_module modules/mod_expires.so
LoadModule headers_module modules/mod_headers.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule http2_module modules/mod_http2.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule autoindex_module modules/mod_autoindex.so
LoadModule dir_module modules/mod_dir.so
LoadModule rewrite_module modules/mod_rewrite.so

# Enables Systemd module when available.
# Required on some operating systems.
# <IfFile modules/mod_systemd.so>
#   LoadModule systemd_module modules/mod_systemd.so
# </IfFile>

<IfModule mod_unixd.c>
    # Run as a unique, less privileged user for security reasons.
    # User/Group: The name (or #number) of the user/group to run httpd as.
    # Default: User #-1, Group #-1
    # https://httpd.apache.org/docs/current/mod/mod_unixd.html
    # https://en.wikipedia.org/wiki/Principle_of_least_privilege
    User www-data
    Group www-data
</IfModule>

# Allows you to bind Apache to specific IP addresses and/or
# ports, instead of the default.
# https://httpd.apache.org/docs/current/mod/mpm_common.html#listen
# https://httpd.apache.org/docs/current/bind.html
Listen 80
Listen 443

# Sets The location of the error log file.
# If you *do* define an error logfile for a <VirtualHost>
# container, that host's errors will be logged there and not here.
# Default: logs/error_log
# https://httpd.apache.org/docs/current/mod/core.html#errorlog
ErrorLog logs/error.log

# Minimum level of messages to be logged to the ErrorLog.
# Default: warn
# https://httpd.apache.org/docs/current/mod/core.html#loglevel
LogLevel warn

<IfModule mod_log_config.c>
    # Defines NCSA Combined Log Format.
    # https://httpd.apache.org/docs/current/mod/mod_log_config.html#logformat
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined

    # The location and format of the access logfile.
    # If you *do* define per-<VirtualHost> access logfiles, transactions will
    # be logged therein and *not* in this file.
    # https://httpd.apache.org/docs/current/mod/mod_log_config.html#customlog
    CustomLog logs/access.log combined
</IfModule>

# Prevent Apache from sending its version number, the description of the
# generic OS-type or information about its compiled-in modules in the "Server"
# response header.
# https://httpd.apache.org/docs/current/mod/core.html#servertokens
ServerTokens Prod
Include h5bp/security/server_software_information.conf

# Prevent Apache from responding to `TRACE` HTTP request.
# The TRACE method, while seemingly harmless, can be successfully
# leveraged in some scenarios to steal legitimate users' credentials.
# https://httpd.apache.org/docs/current/mod/core.html#traceenable
TraceEnable Off

# Enable HTTP/2 protocol
# Default: http/1.1
# https://httpd.apache.org/docs/current/mod/core.html#protocols
Protocols h2 http/1.1

# Blocks access to files that can expose sensitive information.
Include h5bp/security/file_access.conf
<IfModule mod_authz_core.c>
    <LocationMatch "(^|/)\.(?!well-known/)">
        Require all denied
    </LocationMatch>
</IfModule>

# Prevent multiviews errors.
Include h5bp/errors/error_prevention.conf

# Prevent unexpected file accesses and external configuration execution.
# https://httpd.apache.org/docs/current/misc/security_tips.html#systemsettings
# https://httpd.apache.org/docs/current/mod/core.html#allowoverride
# https://httpd.apache.org/docs/current/mod/mod_authz_core.html#require
<Directory "/">
    AllowOverride None
    Require all denied
</Directory>

<IfModule mod_mime.c>
    # TypesConfig points to the file containing the list of mappings from
    # filename extension to MIME-type.
    TypesConfig conf/mime.types
</IfModule>

# Specify MIME types for files.
Include h5bp/media_types/media_types.conf

# Set character encodings.
Include h5bp/media_types/character_encodings.conf

# On systems that support it, memory-mapping or the sendfile syscall may be
# used to deliver files.
# This usually improves server performance, but must be turned off when serving
# from networked-mounted filesystems or if support for these functions is
# otherwise broken on your system.
# Defaults: EnableMMAP On, EnableSendfile Off
# https://httpd.apache.org/docs/current/mod/core.html#enablemmap
# https://httpd.apache.org/docs/current/mod/core.html#enablesendfile
EnableMMAP Off
EnableSendfile On

# Enable gzip compression.
Include h5bp/web_performance/compression.conf

# Specify file cache expiration.
Include h5bp/web_performance/cache_expiration.conf

# Enable rewrite engine.
Include h5bp/rewrites/rewrite_engine.conf

# Include VirtualHost files in the vhosts folder.
# VirtualHost configuration files should be placed in the vhosts folder.
# The configurations should be disabled by prefixing files with a dot.
Include vhosts/*.conf

<IfModule mod_headers.c>
  <IfModule mod_setenvif.c>
    <IfModule mod_fcgid.c>
       SetEnvIfNoCase ^Authorization$ \"(.+)\" XAUTHORIZATION=$1
       RequestHeader set XAuthorization %{XAUTHORIZATION}e env=XAUTHORIZATION
    </IfModule>
    <IfModule mod_proxy_fcgi.c>
       SetEnvIfNoCase Authorization \"(.+)\" HTTP_AUTHORIZATION=$1
    </IfModule>
  </IfModule>
  <IfModule mod_env.c>
    # Add security and privacy related headers
    Header set X-Content-Type-Options \"nosniff\"
    Header set X-XSS-Protection \"1; mode=block\"
    Header set X-Robots-Tag \"none\"
    Header set X-Frame-Options \"SAMEORIGIN\"
    Header set X-Download-Options \"noopen\"
    Header set X-Permitted-Cross-Domain-Policies \"none\"
    SetEnv modHeadersAvailable true
  </IfModule>
  # Add cache control for static resources
  <FilesMatch \"\.(css|js|svg|gif)$\">
    Header set Cache-Control \"max-age=15778463\"
  </FilesMatch>
  
  # Let browsers cache WOFF files for a week
  <FilesMatch \"\.woff$\">
    Header set Cache-Control \"max-age=604800\"
  </FilesMatch>
</IfModule>
<IfModule mod_php5.c>
  php_value upload_max_filesize 511M
  php_value post_max_size 511M
  php_value memory_limit 512M
  php_value mbstring.func_overload 0
  php_value always_populate_raw_post_data -1
  php_value default_charset 'UTF-8'
  php_value output_buffering 0
  <IfModule mod_env.c>
    SetEnv htaccessWorking true
  </IfModule>
</IfModule>
<IfModule mod_php7.c>
  php_value upload_max_filesize 511M
  php_value post_max_size 511M
  php_value memory_limit 512M
  php_value mbstring.func_overload 0
  php_value default_charset 'UTF-8'
  php_value output_buffering 0
  <IfModule mod_env.c>
    SetEnv htaccessWorking false
  </IfModule>
</IfModule>
<IfModule mod_rewrite.c>
  RewriteEngine on
  RewriteRule .* - [env=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
  RewriteRule ^\.well-known/host-meta /public.php?service=host-meta [QSA,L]
  RewriteRule ^\.well-known/host-meta\.json /public.php?service=host-meta-json [QSA,L]
  RewriteRule ^\.well-known/carddav /remote.php/dav/ [R=301,L]
  RewriteRule ^\.well-known/caldav /remote.php/dav/ [R=301,L]
  RewriteRule ^remote/(.*) remote.php [QSA,L]
  RewriteRule ^(?:build|tests|config|lib|3rdparty|templates)/.* - [R=404,L]
  RewriteCond %{REQUEST_URI} !^/.well-known/acme-challenge/.*
  RewriteRule ^(?:\.|autotest|occ|issue|indie|db_|console).* - [R=404,L]
</IfModule>
<IfModule mod_mime.c>
  AddType image/svg+xml svg svgz
  AddEncoding gzip svgz
</IfModule>
<IfModule mod_dir.c>
  DirectoryIndex index.php index.html
</IfModule>
AddDefaultCharset utf-8\n
Options -Indexes\n
<IfModule pagespeed_module>
  ModPagespeed Off
</IfModule>
ErrorDocument 403 //core/templates/403.php
ErrorDocument 404 //core/templates/404.php
