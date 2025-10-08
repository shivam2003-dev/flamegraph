FROM python:3.11-slim

# Install required system packages for perf profiling
RUN apt-get update && apt-get install -y \
    linux-perf \
    git \
    perl \
    wget \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install FlameGraph tools
WORKDIR /opt
RUN git clone https://github.com/brendangregg/FlameGraph.git

# Set up application directory
WORKDIR /app

# Copy application files
COPY app.py /app/
COPY profile.sh /app/

# Make scripts executable
RUN chmod +x /app/profile.sh

# Set environment variables for perf
ENV PERF_EVENT_PARANOID=-1

# Default command
CMD ["/bin/bash"]
