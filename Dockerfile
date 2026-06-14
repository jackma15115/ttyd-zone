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

# 1. 注入 non-free 和 contrib 软件源，否则 p7zip-rar 会报找不到包的错误
RUN sed -i 's/Components: main/Components: main non-free contrib/g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        procps \
        ca-certificates \
        locales \
        net-tools \
        zip \
        jq \
        p7zip-full \
        p7zip-rar \
        vim \
        wget \
        git \
        sudo \
        libxslt1-dev \
        libc-ares-dev && \
    \
    # 2. 配置语言环境
    sed -i -e 's/# \(zh_CN.UTF-8\)/\1/' /etc/locale.gen && \
    echo "Generating locales..." && \
    locale-gen && \
    \
    # 3. 从 GitHub 下载 ttyd 二进制文件
    echo "Downloading ttyd v${TTYD_VERSION} for ${TTYD_ARCH}..." && \
    curl -s -L "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" \
         -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd && \
    \
    # 4. 安装 NVM、Node.js LTS 并全局预装 Wrangler
    echo "Installing nvm, Node.js LTS, and wrangler..." && \
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash && \
    # 加载 nvm 脚本以便在当前 RUN 层中使用
    . "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    nvm use --lts && \
    nvm alias default 'lts/*' && \
    npm install -g wrangler && \
    \
    # 5. 将 Node.js 的全局可执行路径硬链接或软链接到系统 PATH 中，防止非交互式 Shell 找不到 node/wrangler
    ln -s $(nvm which --lts) /usr/local/bin/node && \
    ln -s $(nvm which --lts | sed 's/node$/npm/') /usr/local/bin/npm && \
    ln -s $(nvm which --lts | sed 's/node$/npx/') /usr/local/bin/npx && \
    ln -s $(nvm which --lts | sed 's/bin\/node$/bin\/wrangler/') /usr/local/bin/wrangler && \
    \
    # 6. 确保默认 shell 为 bash
    chsh -s /bin/bash root && \
    \
    # 7. 清理工作 (保留 curl 和证书供后续开发使用)
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 拷贝并赋予执行权限，合并为一个层
COPY --chmod=755 entrypoint.sh /entrypoint.sh

EXPOSE 80 8000 8001 7860

ENTRYPOINT ["/entrypoint.sh"]
