FROM tomcat:latest
MAINTAINER sj <devops@sj.com>
ENV JAVA_OPTS="-Xmx12g -Xms12g"
# War file replacement
RUN rm -rf /usr/local/tomcat/webapps/*
COPY hello-world.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]