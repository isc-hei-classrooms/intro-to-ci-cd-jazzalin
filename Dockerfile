# =========================
# Build stage
# =========================
FROM debian:bookworm AS builder

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential make && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only what is needed for the build
COPY include ./include
COPY src ./src
COPY test ./test
COPY Makefile .

# Build and test
RUN make clean && make && make test

# =========================
# Runtime stage
# =========================
FROM debian:bookworm-slim

# Create a non-root user
RUN useradd -m appuser

WORKDIR /app

# Copy the binary only
COPY --from=builder /app/build/main /app/main

RUN chmod +x /app/main && chown appuser:appuser /app/main

USER appuser

# Default command
ENTRYPOINT ["/app/main"]