# Based on: https://www.teradici.com/web-help/pcoip_client/linux/20.07/reference/creating_a_docker_container/
# Conditional stage Logic based on: https://stackoverflow.com/a/60820156
# This is so annoying: https://stackoverflow.com/questions/64067541/do-i-need-nvidia-container-runtime-and-why

ARG NVIDIA_ENABLED=0

# First, define a 'base' image that's the same for both modes
FROM ubuntu:18.04 as base

# Args
ARG HOST_USERNAME
ARG HOST_UID
ARG HOST_GID
ARG DEBIAN_FRONTEND=noninteractive
ARG LC_ALL=C.UTF-8
ARG LANG=C.UTF-8

# Setup a functional user with the same permissions as your local user.
# https://jtreminio.com/blog/running-docker-containers-as-current-host-user/
RUN groupadd -g ${HOST_GID} ${HOST_USERNAME}
RUN useradd -l -u ${HOST_UID} -g ${HOST_GID} ${HOST_USERNAME}
RUN install -d -m 0755 -o ${HOST_USERNAME} -g ${HOST_GID} /home/${HOST_USERNAME}

# Install the Terradici Client per their instructions
# Enable Beta client builds with the echo "deb [arch=amd64]...." command
RUN apt-get update && apt-get install -y wget apt-transport-https apt-utils
RUN wget -O teradici-repo-latest.deb https://downloads.teradici.com/ubuntu/teradici-repo-bionic-latest.deb
RUN apt-get install ./teradici-repo-latest.deb
RUN echo "deb [arch=amd64] https://downloads.teradici.com/ubuntu bionic-beta non-free" > /etc/apt/sources.list.d/pcoip.list
RUN apt-get update && apt-get install --no-install-recommends -y pcoip-client

# Pulseaudio for audio support
RUN apt-get update && apt-get install -y pulseaudio

# Define a variant for non-nvidia accelerated setups; no different from base!
FROM base AS branch-version-0
RUN apt-get install -y mesa-utils libgl1-mesa-glx libnvidia-gl-470

# Next, Define a variant for nvidia-based setups
# Thanks https://stackoverflow.com/a/44187181 !!!
FROM base AS branch-version-1
ARG NVIDIA_DRIVER_VERSION

# My 418.181.07 driver from Debian 10 apt comes from an Nvidia "tesla"
# download URL.  Your driver might come from an "XFree86" URL.  So, we
# try both.
RUN if [ "${NVIDIA_DRIVER_VERSION}" ]; then \
    apt-get install -y libgl1-mesa-glx libgl1-mesa-dri mesa-utils module-init-tools; \
    wget -cO NVIDIA-DRIVER.run http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run || \
    wget -cO NVIDIA-DRIVER.run http://us.download.nvidia.com/tesla/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run; \
    chmod a+x NVIDIA-DRIVER.run; \
    ./NVIDIA-DRIVER.run -a -N --ui=none --no-kernel-module; \
	fi

# Create 'final' using whichever branch was specified
FROM branch-version-${NVIDIA_ENABLED} AS final

ARG HOST_USERNAME

# Become the container's copy of our host's user
USER ${HOST_USERNAME}
ENV HOME /home/${HOST_USERNAME}

# pcoip-client writes pulseaudio data under here
RUN mkdir /home/${HOST_USERNAME}/.config
RUN chown ${HOST_USERNAME}:${HOST_GID} /home/${HOST_USERNAME}/.config

# Set the path for QT to find the keyboard context
ENV QT_XKB_CONFIG_ROOT /usr/share/X11/xkb

# Enter!
ENTRYPOINT pcoip-client

