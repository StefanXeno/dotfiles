ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl \
    git  \
    sudo \
    ca-certificates \
    iproute2 \
    rsync \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG USERNAME=stefan
ARG USER_UID=1000
ARG USER_GID=1000

RUN \
    if getent passwd ${USER_UID} > /dev/null 2>&1; then \
        existing_user=$(getent passwd ${USER_UID} | cut -d: -f1); \
        userdel -r "$existing_user" 2>/dev/null || true; \
    fi \
    && if getent group ${USER_GID} > /dev/null 2>&1; then \
        existing_group=$(getent group ${USER_GID} | cut -d: -f1); \
        groupdel "$existing_group" 2>/dev/null || true; \
    fi \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd \
        --uid ${USER_UID} \
        --gid ${USER_GID} \
        --create-home \
        --shell /bin/bash \
        ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Rootless Docker starts `docker exec` with umask 0000 - keep zsh sessions at the usual 022.
# ~/.zshenv is not part of any stow package, and /etc/zsh/zshenv would clash with the zsh package.
RUN echo 'umask 022' > /home/${USERNAME}/.zshenv \
    && chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.zshenv

USER ${USERNAME}
WORKDIR /home/${USERNAME}

CMD ["sleep", "infinity"]