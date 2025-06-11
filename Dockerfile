FROM ubuntu:24.04 as build

# prevent the timezone question
ARG DEBIAN_FRONTEND=noninteractive

# install the initial stuff
RUN apt-get update && \
    apt-get install -y \
        binutils-mips-linux-gnu \
        bsdmainutils \
        build-essential \
        libaudiofile-dev \
        pkg-config \
        python3 \
        wget \
        zlib1g-dev \
	curl


# install the devkitpro repo and dkp-pacman
#
# note that the install-devkitpro-pacman script will abort on the apt question;
# we will ignore that exit code and install devkitpro-pacman in a separate cmd 

RUN curl https://apt.devkitpro.org/install-devkitpro-pacman | bash || : 

# fix the no /etc/mtab directory issue
RUN ln -s /proc/self/mounts /etc/mtab

RUN apt install devkitpro-pacman -y


RUN dkp-pacman -Syu 3ds-dev --noconfirm

RUN mkdir /sm64
WORKDIR /sm64

ENV PATH="/opt/devkitpro/tools/bin/:/sm64/tools:${PATH}"
ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=/opt/devkitpro/devkitARM
ENV DEVKITPPC=/opt/devkitpro/devkitPPC

CMD echo 'usage: docker run --rm --mount type=bind,source="$(pwd)",destination=/sm64 sm64 make VERSION=${VERSION:-us} -j4\n' \
         'see https://github.com/n64decomp/sm64/blob/master/README.md for advanced usage'
