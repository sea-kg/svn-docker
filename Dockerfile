# Alpine Linux with s6 service management
FROM smebberson/alpine-base:3.2.0

	# Install Apache2 and other stuff needed to access svn via WebDav
	# Install svn
	# Installing utilities for SVNADMIN frontend
	# Create required folders
	# Create the authentication file for http access
	# Getting SVNADMIN interface
RUN apk add --no-cache apache2 apache2-utils apache2-webdav mod_dav_svn &&\
	apk add --no-cache subversion &&\
	apk add --no-cache wget unzip php7 php7-apache2 php7-session php7-json php7-ldap &&\
	apk add --no-cache php7-xml &&\	
	sed -i 's/;extension=ldap/extension=ldap/' /etc/php7/php.ini &&\
	mkdir -p /run/apache2/

# Solve a security issue (https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html)	
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

# Basicly from https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.zip
# + patches
ADD svn-server/opt/default_data /opt/default_data
ADD iF.SVNAdmin /opt/svnadmin
RUN ln -s /opt/svnadmin /var/www/localhost/htdocs/svnadmin &&\
	rm -rf /opt/svnadmin/data

# Add services configurations
ADD svn-server/etc/services.d/apache2/run /etc/services.d/apache2/run
ADD svn-server/etc/services.d/subversion/run /etc/services.d/subversion/run

# default environment paths
ENV SVN_SERVER_REPOSITORIES_URL=/svn

# Add WebDav configuration
ADD svn-server/etc/apache2/conf.d/dav_svn.conf /etc/apache2/conf.d/dav_svn.conf

# Add svn admin configuration
ADD svn-server/etc/apache2/conf.d/svnadmin.conf /etc/apache2/conf.d/svnadmin.conf

# Set HOME in non /root folder
# ENV HOME /home

# USER apache

# Expose ports for http and custom protocol access
EXPOSE 80
