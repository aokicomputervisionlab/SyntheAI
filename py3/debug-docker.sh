# ビルド
docker build -t synthai-debug -f Dockerfile.debug .
docker run --rm --gpus all \
  -v $(pwd):/app \
  synthai-debug \
  /bin/bash -c "
    set -e  # エラーが起きたらその場で止まるように設定

    echo '--- 1. Generating requirements.txt ---'
    pip-compile --strip-extras --upgrade \
      --unsafe-package nvidia-cublas-cu12 \
      --unsafe-package nvidia-cuda-cupti-cu12 \
      --unsafe-package nvidia-cuda-nvcc-cu12 \
      --unsafe-package nvidia-cuda-nvrtc-cu12 \
      --unsafe-package nvidia-cuda-runtime-cu12 \
      --unsafe-package nvidia-cudnn-cu12 \
      --unsafe-package nvidia-cufft-cu12 \
      --unsafe-package nvidia-curand-cu12 \
      --unsafe-package nvidia-cusolver-cu12 \
      --unsafe-package nvidia-cusparse-cu12 \
      --unsafe-package nvidia-nccl-cu12 \
      --unsafe-package nvidia-nvtx-cu12 \
      requirements.in --output-file requirements.txt
    echo '--- 2. Installing Requirements ---'
    pip install -r requirements.txt
    echo '--- 4. Testing TensorFlow ---'
    python3 <<EOF
import tensorflow as tf
from tensorflow.python.client import device_lib
import os

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '0'
print('--- TF Device Check Start ---')
gpus = tf.config.list_physical_devices('GPU')
print(f'Detected GPUs (list_physical_devices): {gpus}')

if not gpus:
    print('Searching deeper with device_lib...')
    devices = device_lib.list_local_devices()
    for d in devices:
        print(f' - Device: {d.name}, Type: {d.device_type}')

assert len(gpus) > 0, 'TensorFlow cannot see GPU even with system libraries!'
print('--- TF GPU Test Passed! ---')
EOF
    echo '--- 5. Testing Others ---'
    python3 <<EOF
import os
import tensorflow as tf
import torch
import jax

# TF Check
gpus = tf.config.list_physical_devices('GPU')
print(f'TF GPUs: {gpus}')

# Torch Check
print(f'Torch CUDA: {torch.cuda.is_available()}')

# JAX Check
jax_gpu = jax.lib.xla_bridge.get_backend().platform
print(f'JAX Platform: {jax_gpu}')

# Final Assert
assert len(gpus) > 0, 'TF failed'
assert torch.cuda.is_available(), 'Torch failed'
assert jax_gpu == 'gpu', 'JAX failed'

print('--- ALL FRAMEWORKS SUCCESS ---')
EOF
  
    echo '--- SUCCESS ---'
"