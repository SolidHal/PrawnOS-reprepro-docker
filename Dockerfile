FROM debian:bullseye
MAINTAINER Hal 'SoldHal' Emmerich <hal@halemmerich.com>
ENV DEBIAN_FRONTEND noninteractive

# Install the necessary packages
RUN apt-get update
RUN apt-get install -y sudo openssh-server nginx reprepro inoticoming

# Setup user and group
RUN addgroup --system debian
RUN adduser --system --shell /bin/bash --disabled-password --ingroup debian --home /home/debian debian
# Add the user to sudo
RUN adduser debian sudo

# Prepare the home, .ssh and .gnupg folders
RUN mkdir -p /home/debian/.ssh
RUN mkdir -p /home/debian/.gnupg
RUN chown -R debian:debian /home/debian/

# We need privilege separation
RUN mkdir -p /var/run/sshd

# Allow user debian to sudo without password
RUN echo "debian ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Transfer template files
ADD ./templates/ /templates/

# Open ports for nginx and ssh server
EXPOSE 80
EXPOSE 22

#Prepare the build scripts
COPY build.sh build.sh
RUN chmod +x build.sh
CMD ["/bin/bash", "build.sh"]
#CMD ["/bin/bash"]
