FROM envoyproxy/envoy:17efc838016101f7607fbb9a27151da606e0bd13
#FROM vifoggy/envoy:1.8

FROM turbinelabs/envtemplate:0.19.0

FROM phusion/baseimage:0.10.2

RUN groupadd -r envoy && useradd -r -g envoy envoy 
# upgrade/install deps
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y
RUN apt install -y net-tools iproute2 iptables

# install envoy binary
COPY --from=0 /usr/local/bin/envoy /usr/local/bin/envoy

# install envtemplate
COPY --from=1 /usr/local/bin/envtemplate /usr/local/bin/envtemplate

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add boostrap config file
ADD bootstrap.conf.tmpl /etc/envoy/bootstrap.conf.tmpl
RUN chmod a+w /etc/envoy

# add start script
ADD start-envoy.sh /usr/local/bin/start-envoy.sh
RUN chmod +x /usr/local/bin/start-envoy.sh

# These are best guesses
EXPOSE 80 443 9999

# Use baseimage-docker's init system.
#CMD ["/sbin/my_init", "--","setuser","envoy","bash","/usr/local/bin/start-envoy.sh"]
CMD ["bash","/usr/local/bin/start-envoy.sh"]
