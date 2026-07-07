FROM python:3.12-slim
WORKDIR /AstrBot

# 系统依赖（不常变，优先安装以利用 Docker 层缓存）
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    python3-dev \
    libffi-dev \
    libssl-dev \
    ca-certificates \
    bash \
    ffmpeg \
    libavcodec-extra \
    curl \
    gnupg \
    git \
    ripgrep \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 只复制依赖文件（代码不变时，依赖安装层走缓存）
COPY requirements.txt ./

RUN python -m pip install uv --no-cache-dir \
    && uv pip install -r requirements.txt --no-cache-dir --system \
    && uv pip install socksio uv pilk --no-cache-dir --system

# 最后复制代码（经常变，但不触发依赖重装）
COPY . /AstrBot/

EXPOSE 6185

CMD ["python", "main.py"]
