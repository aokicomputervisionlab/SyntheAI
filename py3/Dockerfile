FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04

# TimeZone　Setup
ENV DEBIAN_FRONTEND=noninteractive TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Base Environment Setup
RUN apt-get update && apt-get install -y \ 
    tzdata \
    git \ 
    wget \
    libglib2.0-0 \
    libsm6 \ 
    libxrender1 \ 
    libxext6 \
    libgl1-mesa-dev \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

# copy to requirements.txt and requirements install 
COPY requirements.txt /install/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r /install/requirements.txt

# Tensorflow Log Level Setup(Delete Warning Message)
ENV TF_CPP_MIN_LOG_LEVEL=2
