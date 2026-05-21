FROM ubuntu:22.04

# Установка базовых инструментов
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    # SSH и Git
    openssh-server \
    git \
    git-lfs \
    # Языки программирования
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    # Инструменты разработки
    curl \
    wget \
    vim \
    htop \
    sudo \
    # Для работы с Forgejo API
    jq \
    # Очистка
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Установка uv (быстрый pip)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Настройка SSH
RUN mkdir /var/run/sshd
COPY docker/ssh-setup.sh /usr/local/bin/ssh-setup.sh
RUN chmod +x /usr/local/bin/ssh-setup.sh

# Создание пользователя разработчика
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Настройка SSH для пользователя
RUN mkdir -p /home/$USERNAME/.ssh \
    && chmod 700 /home/$USERNAME/.ssh \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# Установка рабочей директории
WORKDIR /workspace
RUN chown -R $USERNAME:$USERNAME /workspace

# SSH конфигурация
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
    && echo "UsePAM no" >> /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
