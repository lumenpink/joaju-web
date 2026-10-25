# ==============================================================================
# Stage 1: Build native Rust binary
# ==============================================================================
FROM rust:latest AS builder

WORKDIR /app

# Configure sovereign lumen Cargo registry (sparse index over HTTPS, zero auth needed for download)
RUN mkdir -p /usr/local/cargo && \
    cat <<'EOF' > /usr/local/cargo/config.toml
[registries.lumen]
index = "sparse+https://gambi.2lp.in/api/packages/lumen/cargo/"
EOF

COPY . .

RUN cargo build --release

# ==============================================================================
# Stage 2: Final runtime image (Debian slim, non-root)
# ==============================================================================
FROM debian:bookworm-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PORT=3000

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    fonts-liberation \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash joaju

WORKDIR /app

RUN mkdir -p /data /tmp /app \
    && chown -R joaju:joaju /app /data /tmp \
    && chmod 1777 /tmp

COPY --chown=joaju:joaju --from=builder /app/target/release/joaju-web /usr/local/bin/joaju-web
COPY --chown=joaju:joaju public /app/public
COPY --chown=joaju:joaju locales /app/locales
COPY --chown=joaju:joaju site /app/site

USER joaju

EXPOSE 3000

CMD ["/usr/local/bin/joaju-web"]
