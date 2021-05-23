FROM jenkinsci/blueocean:latest

USER root

RUN apk --no-cache add supervisor \
    && mkdir -p /var/log/supervisord \
    && chown -R jenkins:jenkins /var/log/supervisord
COPY supervisord.conf /etc/supervisord.conf

RUN mkdir /var/log/jenkins \
    && mkdir /var/cache/jenkins \
    && chown -R jenkins:jenkins /var/log/jenkins \
    && chown -R jenkins:jenkins /var/cache/jenkins

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

USER jenkins

ENV JENKINS_USER admin
ENV JENKINS_PASS admin
ENV JENKINS_OPTS="--logfile=/var/log/jenkins/jenkins.log"
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

RUN jenkins-plugin-cli --plugins \
    docker-plugin \
    docker-workflow \
    authorize-project \
    gitea \
    credentials

COPY set-root-url.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY set-executors.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY set-default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY set-agent-master-access-control.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY set-access-control-builds.groovy /usr/share/jenkins/ref/init.groovy.d/

VOLUME /var/jenkins_home