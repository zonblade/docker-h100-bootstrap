# Use NVIDIA CUDA base image with Python 3.10
FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV CUDA_VISIBLE_DEVICES=0,1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3-pip \
    python3.10-venv \
    git \
    wget \
    curl \
    build-essential \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for python
RUN ln -s /usr/bin/python3.10 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel

# Install PyTorch with CUDA support first
RUN pip install torch==2.1.0+cu121 torchvision==0.16.0+cu121 torchaudio==2.1.0+cu121 \
    --index-url https://download.pytorch.org/whl/cu121

# Install other requirements
RUN pip install -r requirements.txt

# Copy source code
COPY src/ ./src/
COPY models/ ./models/ 2>/dev/null || echo "Models directory not found, will be mounted or downloaded"

# Create necessary directories
RUN mkdir -p models logs

# Copy any additional configuration files if needed
# COPY config/ ./config/ 2>/dev/null || echo "No config directory found"

# Set Python path
ENV PYTHONPATH=/app:$PYTHONPATH

# Create a startup script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "Starting Vulnerability Detection API..."\n\
echo "Available GPUs:"\n\
nvidia-smi --list-gpus || echo "nvidia-smi not available"\n\
\n\
echo "CUDA Visible Devices: $CUDA_VISIBLE_DEVICES"\n\
echo "PyTorch CUDA available: $(python -c \"import torch; print(torch.cuda.is_available())\")"\n\
echo "PyTorch CUDA device count: $(python -c \"import torch; print(torch.cuda.device_count())\")"\n\
\n\
# Test PyTorch GPU access\n\
python -c "import torch; print(f\"PyTorch version: {torch.__version__}\"); print(f\"CUDA available: {torch.cuda.is_available()}\"); [print(f\"GPU {i}: {torch.cuda.get_device_name(i)}\") for i in range(torch.cuda.device_count())]"\n\
\n\
# Start the API\n\
exec uvicorn src.main:app --host 0.0.0.0 --port 8000 --workers 1\n\
' > /app/start.sh && chmod +x /app/start.sh

# Expose port
EXPOSE 8000

# Set the startup command to bash for development workspace
CMD ["/bin/bash"]