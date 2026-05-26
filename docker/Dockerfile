FROM ubuntu:22.04

# Установка базовых инструментов
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8
ENV TZ=Europe/Moscow

# Очистка кэша и обновление с ретраями
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common

# Добавление репозиториев для свежих пакетов
RUN add-apt-repository -y ppa:git-core/ppa && \
    add-apt-repository -y ppa:deadsnakes/ppa

# Установка основных пакетов (разбиваем на этапы)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        git \
        git-lfs \
        curl \
        wget \
        sudo \
        && rm -rf /var/lib/apt/lists/*

# Установка Python и Node.js
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        nodejs \
        npm \
        && rm -rf /var/lib/apt/lists/*

# Установка утилит (проблемные пакеты устанавливаем отдельно)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vim \
        htop \
        jq \
        nano \
        && rm -rf /var/lib/apt/lists/*

# Установка MC и кириллицы с игнорированием ошибок
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        mc \
        locales \
        && rm -rf /var/lib/apt/lists/*

# Установка остальных пакетов для кириллицы
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        keyboard-configuration \
        console-data \
        fonts-freefont-ttf \
        fonts-dejavu-core \
        && rm -rf /var/lib/apt/lists/*

# Настройка локали
RUN locale-gen ru_RU.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8

# Установка uv
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

RUN ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" && \
    ssh-keygen -t ecdsa -b 521 -f /etc/ssh/ssh_host_ecdsa_key -N "" && \
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# Создание пользователя разработчика
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Создание скрипта настройки Git
COPY docker/git-setup.sh /usr/local/bin/git-setup.sh
RUN chmod +x /usr/local/bin/git-setup.sh

# Настройка окружения для пользователя
RUN echo "alias ll='ls -la'" >> /home/$USERNAME/.bashrc && \
    echo "alias ls='ls --color=auto'" >> /home/$USERNAME/.bashrc && \
    echo "alias mc='mc -S gotar'" >> /home/$USERNAME/.bashrc && \
    echo "source /usr/local/bin/git-setup.sh" >> /home/$USERNAME/.bashrc && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc

# Создать временный файл и добавить его в .bashrc
RUN cat >> /home/developer/.bashrc << 'EOF'

# Настройка поиска по истории с PageUp/PageDown
if [[ $- == *i* ]]; then
    bind '"\e[5~": history-search-backward'
    bind '"\e[6~": history-search-forward'
fi
EOF


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

# Настройка правильной оболочки ---
RUN chsh -s /bin/bash developer

# Настройка терминала для пользователя
RUN echo "export TERM=xterm-256color" >> /home/developer/.bashrc && \
    echo "export SHELL=/bin/bash" >> /home/developer/.bashrc && \
    echo "set -o emacs" >> /home/developer/.bashrc && \
    echo "export LANG=ru_RU.UTF-8" >> /home/developer/.bashrc && \
    echo "export LC_ALL=ru_RU.UTF-8" >> /home/developer/.bashrc

# Установка bash-completion (опционально) ----
RUN apt-get update && apt-get install -y bash-completion && \
    echo "source /usr/share/bash-completion/bash_completion" >> /home/developer/.bashrc

# Установка рабочей директории
# WORKDIR /workspace
# НЕ создаем папку и не меняем владельца, так как она смонтирована с хоста
#RUN chown -R $USERNAME:$USERNAME /workspace

# SSH конфигурация
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "ObscureKeystrokeTiming no" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
    && echo "UsePAM no" >> /etc/ssh/sshd_config \
    && echo "AcceptEnv LANG LC_ALL LANGUAGE" >> /etc/ssh/sshd_config

EXPOSE 22

CMD ["sh", "-c", "ssh-keygen -A 2>/dev/null || true && /usr/sbin/sshd -D"]