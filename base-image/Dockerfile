FROM phusion/baseimage:master

WORKDIR /

COPY id_rsa .

COPY install_applications.sh .

COPY bitbucket_manager.py .

RUN ./install_applications.sh