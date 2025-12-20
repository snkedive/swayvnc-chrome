FROM debian:sid-slim
LABEL org.opencontainers.image.source="https://github.com/snkedive/swayvnc-chrome"

ARG USER=chrome-user
ARG PUID=1000
ARG PGID=1000
ARG RENDER_GROUP_GID=993

ENV DOCKER_USER=$USER
ENV PUID=$PUID
ENV PGID=$PGID

USER root
RUN groupadd -g $PGID $DOCKER_USER
RUN groupadd -g $RENDER_GROUP_GID docker-render
RUN useradd -ms /bin/bash -u $PUID -g $PGID $USER
RUN usermod -aG docker-render $USER

RUN apt-get update

# Install sway/wayvnc and dependencies
RUN apt-get install -y --no-install-recommends \
    sway wayvnc openssh-client openssl curl ca-certificates chromium-browser

# Clean up apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy sway/wayvnc configs
COPY --chown=$USER:$USER sway/config /home/$USER/.config/sway/config
COPY --chown=$USER:$USER wayvnc/config /home/$USER/.config/wayvnc/config

# Make directory for wayvnc certs
RUN mkdir /certs
RUN chown -R $USER:$USER /certs

# Copy and set the entrypoint script
COPY --chown=$USER:$USER entrypoint.sh /
COPY --chown=$USER:$USER entrypoint_user.sh /
ENTRYPOINT ["/entrypoint.sh"]
