FROM tensorflow/tensorflow:2.15.0.post1-gpu
# TimeZone　Setup
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

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
# Install for PyTorch Library
RUN pip install torch==2.7.1 torchvision==0.22.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cu118

# Tensorflow Log Level Setup(Delete Warning Message)
ENV TF_CPP_MIN_LOG_LEVEL=2
