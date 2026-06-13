FROM debian:bookworm-slim

LABEL maintainer="your-email@example.com"

ENV TTYD_VERSION="1.7.7"
ENV TTYD_ARCH="x86_64"

# 配置环境变量，统一字符集
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

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
        libc-ares-dev \
        nodejs \
        npm && \
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
    # 3. 预装 wrangler (npx 包含在 npm 中，全局安装可确保开箱即用)
    echo "Installing wrangler globally..." && \
    npm install -g wrangler && \
    \
    # 4. 清理工作：保留必要的 curl 和证书，只清理 apt 缓存减小体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

# 给予脚本执行权限
RUN chmod +x /entrypoint.sh

EXPOSE 80 8000 8001 7860

ENTRYPOINT ["/entrypoint.sh"]
