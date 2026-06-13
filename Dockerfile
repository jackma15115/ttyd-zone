FROM debian:bookworm-slim

LABEL maintainer="your-email@example.com"

ENV TTYD_VERSION="1.7.7"
ENV TTYD_ARCH="x86_64"

# 配置语言环境变量
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

# 配置 NVM 环境变量
ENV NVM_DIR="/root/.nvm"
ENV NVM_VERSION="v0.39.7"

RUN apt-get update && \
    apt-get install -y \
        curl \
        procps \
        ca-certificates \
        locales \
        net-tools \
        zip \
        p7zip-full \
        vim \
        wget \
        git \
        sudo \
        libxslt1-dev \
        libc-ares-dev && \
    \
    # 1. 配置语言环境
    sed -i -e 's/# \(zh_CN.UTF-8\)/\1/' /etc/locale.gen && \
    echo "Generating locales..." && \
    locale-gen && \
    \
    # 2. 从 GitHub 下载 ttyd 二进制文件
    echo "Downloading ttyd v${TTYD_VERSION} for ${TTYD_ARCH}..." && \
    curl -s -L "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" \
         -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd && \
    \
    # 3. 安装 NVM、Node.js LTS 并全局预装 Wrangler
    echo "Installing nvm, Node.js LTS, and wrangler..." && \
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash && \
    # 加载 nvm 脚本以便在当前 RUN 层中使用
    . "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    nvm use --lts && \
    nvm alias default 'lts/*' && \
    npm install -g wrangler && \
    \
    # 4. 确保默认 shell 为 bash，这样登录时能正确读取 ~/.bashrc 中的 nvm 配置
    chsh -s /bin/bash root && \
    \
    # 5. 清理工作 (保留 curl 和证书供后续开发使用)
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

# 给予脚本执行权限
RUN chmod +x /entrypoint.sh

EXPOSE 80 8000 8001 7860

ENTRYPOINT ["/entrypoint.sh"]
