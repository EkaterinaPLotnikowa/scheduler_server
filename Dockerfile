# Этап сборки (builder)
FROM rust:1.74.1-slim-bullseye as builder

# 1. Создаем новый проект и копируем файлы
RUN USER=root cargo new --bin /scheduler
WORKDIR /scheduler

# Сначала копируем только зависимости для кэширования
COPY ./Cargo.toml ./Cargo.lock ./
RUN mkdir -p ./src && touch ./src/lib.rs && \
    cargo build --release && \
    rm -r ./target/release/.fingerprint/scheduler-*

# Затем копируем весь исходный код
COPY ./src ./src
RUN cargo build --release

# Этап запуска
FROM debian:bookworm-slim

# Устанавливаем зависимости
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    openssl \
    gnupg \
    gcc && \
    rm -rf /var/lib/apt/lists/*

# Устанавливаем Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Копируем бинарник из этапа builder
COPY --from=builder /scheduler/target/release/activities-scheduler-server /app/
COPY ./setup.toml /app/

WORKDIR /app
CMD ["./activities-scheduler-server"]