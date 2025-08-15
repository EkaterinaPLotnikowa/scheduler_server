# Этап сборки
FROM rust:1.74.1-slim-bullseye AS builder

WORKDIR /scheduler
COPY . .

# Устанавливаем зависимости и собираем
RUN cargo build --release

# Финальный образ
FROM debian:bookworm-slim

# Минимальные зависимости для работы Rust-бинарника
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Копируем только бинарник
COPY --from=builder /scheduler/target/release/activities-scheduler-server /app/

WORKDIR /app
CMD ["./activities-scheduler-server"]