#######################################################################
# image: leihs/ansible-controller                                     #
# > debian container with everything needed to build and deploy leihs #
#######################################################################

# NOTE: use ruby image (itself based on `debian:buster-slim`, so the version is recent, precompiled, and 'bundler/inline' works)
#       this is a good compromise as long as all the other steps are rather quick,
#       if we ever need to base it on several base images, we'll need to look into multi-stage builds <https://docs.docker.com/develop/develop-images/multistage-build/>
FROM ruby:2.7-slim-buster

# BASE CONFIG
ENV DEBIAN_FRONTEND noninteractive
# locale
RUN apt-get update && apt-get install -y locales locales-all && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# BASE PACKAGES
RUN apt-get update && \
    apt-get install -fy \
    git curl vim gnupg software-properties-common \
    gcc libcurl4-openssl-dev libxml2-dev \
    build-essential libssl-dev libyaml-dev python2.7 python2.7-dev python-pip libffi-dev

# JAVA 8
RUN mkdir -p /usr/share/man/man1/
RUN curl https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && apt-get update && \
    apt-get -fy install adoptopenjdk-8-hotspot

# NODEJS 12
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash \
    && apt-get install nodejs -yq

# BOOT
ENV BOOT_AS_ROOT yes
ENV BOOT_VERSION 2.8.3
# ENV BOOT_CLOJURE_VERSION 1.9.0
RUN cd /usr/local/bin && \
    curl -fsSLo boot https://github.com/boot-clj/boot-bin/releases/download/latest/boot.sh && \
    chmod 755 boot

# AWS CLI
RUN apt-get update && apt-get install -fy awscli

# ANSIBLE
COPY ["./ansible-requirements.txt", "/tmp/ansible-requirements.txt"]
RUN pip install -r "/tmp/ansible-requirements.txt" && rm "/tmp/ansible-requirements.txt"

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_SSH_PIPELINING True
# ENV PATH /ansible/bin:$PATH
# ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
# ENV PYTHONPATH /ansible/lib
# ENV ANSIBLE_LIBRARY /ansible/library


VOLUME [ "/leihs" ]
WORKDIR /leihs/deploy
# ENTRYPOINT ["ansible-playbook"]

