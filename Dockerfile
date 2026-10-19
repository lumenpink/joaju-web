# ==============================================================================
# Stage 1: Build native Rust binary
# ==============================================================================
FROM rust:latest AS builder

WORKDIR /build

# Copy dependency crates
COPY joaju-csv ./joaju-csv
COPY joaju-table ./joaju-table
COPY joaju-unfurl ./joaju-unfurl
COPY joaju-pedigree ./joaju-pedigree
COPY joaju ./joaju
COPY joaju-web ./joaju-web

WORKDIR /build/joaju-web

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

COPY --chown=joaju:joaju --from=builder /build/joaju-web/target/release/joaju-web /usr/local/bin/joaju-web
COPY --chown=joaju:joaju joaju-web/public /app/public
COPY --chown=joaju:joaju joaju-web/locales /app/locales
COPY --chown=joaju:joaju joaju-web/site /app/site

USER joaju

EXPOSE 3000

CMD ["/usr/local/bin/joaju-web"]
