FROM centos
MAINTAINER babu.m@connectio.co.in
RUN yum update -y
RUN yum install httpd -y
RUN echo "hi welcome to the world" > /var/www/html/index.html
ENTRYPOINT ["/usr/sbin/httpd"]
EXPOSE 80
CMD ["-D", "FOREGROUND"]



