# 'dev' or 'release' container build
ARG BUILD_TYPE=dev

# Use an official Python base image from the Docker Hub
FROM python:3.10-slim AS autogpt-base

# Install browsers
RUN apt-get update && apt-get install -y \
    chromium-driver firefox-esr \
    ca-certificates

# Install utilities
RUN apt-get install -y curl jq wget git
RUN apt-get install -y texlive r-base
RUN apt-get install -y poppler-utils

#RUN Rscript -e "install.packages(c('tidyverse', 'ggplot2'))"
RUN pip3 install numpy scipy statsmodels pandas plotly matplotlib scikit-learn

# Run as user, not root
#RUN useradd -d /app -m -s /bin/bash autogpt && echo "autogpt:econ" | chpasswd && adduser autogpt sudo
#USER autogpt

COPY requirements.txt .

# Set environment variables
ENV PIP_NO_CACHE_DIR=yes \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install the required python packages globally
ENV PATH="$PATH:/root/.local/bin:/app/.local/bin"

# Set the entrypoint
ENTRYPOINT ["python", "-m", "autogpt"]

# dev build -> include everything
FROM autogpt-base as autogpt-dev
RUN pip install --no-cache-dir -r requirements.txt
WORKDIR /app
ONBUILD COPY . ./


# release build -> include bare minimum
FROM autogpt-base as autogpt-release
RUN sed -i '/Items below this point will not be included in the Docker Image/,$d' requirements.txt && \
	pip install --no-cache-dir -r requirements.txt
WORKDIR /app
ONBUILD COPY autogpt/ ./autogpt
ONBUILD COPY scripts/ ./scripts


FROM autogpt-${BUILD_TYPE} AS auto-gpt
