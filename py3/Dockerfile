FROM tensorflow/tensorflow:2.15.0.post1-gpu
# TimeZone　Setup
ENV TZ=Asia/Tokyo
ENV DEBIAN_FRONTEND=noninteractive

# Base Environment Setup
RUN apt-get update && apt-get install -y \
    tzdata \
    git \
    wget \
    ffmpeg \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# copy to requirements.txt and requirements install 
COPY requirements.txt /install/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r /install/requirements.txt
# Tensorflow Log Level Setup(Delete Warning Message)
ENV TF_CPP_MIN_LOG_LEVEL=2
