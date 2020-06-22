FROM tomcat:latest
MAINTAINER sj <devops@sj.com>
ARG HEAP_SIZE
ENV JAVA_OPTS="-Xmx${HEAP_SIZE} -Xms${HEAP_SIZE}"
# War file replacement
RUN rm -rf /usr/local/tomcat/webapps/*
COPY hello-world.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]

