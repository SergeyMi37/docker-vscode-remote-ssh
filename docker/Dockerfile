FROM ubuntu:22.04

# Установка базовых инструментов
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8

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
    jq \
    # Midnight Commander и кириллица
    mc \
    nano \
    locales \
    locales-all \
    keyboard-configuration \
    console-data \
    # Шрифты для кириллицы
    fonts-freefont-ttf \
    fonts-dejavu-core \
    # Очистка
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Настройка локали для кириллицы
RUN locale-gen ru_RU.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8

# Установка uv (быстрый pip)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Настройка SSH
RUN mkdir /var/run/sshd
COPY docker/ssh-setup.sh /usr/local/bin/ssh-setup.sh
RUN chmod +x /usr/local/bin/ssh-setup.sh

# Настройка MC для кириллицы
RUN echo "[Midnight Commander]\n\
use_internal_edit=true\n\
editor_wordwrap=false\n\
editor_line_state=false\n\
editor_tab_spacing=4\n\
confirm_exit=true\n\
confirm_delete=true\n\
xterm_title=true\n\
skin=default\n\
\n\
[Colors]\n\
base_color=normal=white,default,default:selected=black,cyan,default:marked=yellow,blue,default:markselect=yellow,blue,default\n\
\n\
[Misc]\n\
dialogs_subshell=false\n\
use_subshell=true" > /etc/mc/mc.ini

# Настройка bash для кириллицы
RUN echo "export LANG=ru_RU.UTF-8" >> /etc/profile.d/lang.sh && \
    echo "export LC_ALL=ru_RU.UTF-8" >> /etc/profile.d/lang.sh && \
    echo "export LANGUAGE=ru_RU:ru" >> /etc/profile.d/lang.sh && \
    chmod +x /etc/profile.d/lang.sh

# Создание пользователя разработчика
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Настройка окружения для пользователя
RUN echo "export LANG=ru_RU.UTF-8" >> /home/$USERNAME/.bashrc && \
    echo "export LC_ALL=ru_RU.UTF-8" >> /home/$USERNAME/.bashrc && \
    echo "export LANGUAGE=ru_RU:ru" >> /home/$USERNAME/.bashrc && \
    echo "alias mc='mc --utf8'" >> /home/$USERNAME/.bashrc && \
    echo "alias ll='ls -la'" >> /home/$USERNAME/.bashrc && \
    echo "alias ls='ls --color=auto'" >> /home/$USERNAME/.bashrc && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc

# Настройка MC для пользователя
RUN mkdir -p /home/$USERNAME/.config/mc && \
    echo "[Midnight Commander]\n\
skin=default\n\
editor_encoding=UTF-8\n\
display_encoding=UTF-8\n\
source_encoding=CP1251" > /home/$USERNAME/.config/mc/ini && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.config

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
    && echo "UsePAM no" >> /etc/ssh/sshd_config \
    && echo "AcceptEnv LANG LC_ALL LANGUAGE" >> /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]