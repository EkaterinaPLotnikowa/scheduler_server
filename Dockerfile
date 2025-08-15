FROM rust:1.74.1-slim-bullseye AS builder
COPY . /app
WORKDIR /app
RUN cargo build --release

FROM debian:bookworm-slim
COPY --from=builder /app/target/release/activities-scheduler-server /app/
CMD ["/app/activities-scheduler-server"]