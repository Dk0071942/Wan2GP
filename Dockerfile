# Use NVIDIA CUDA base image with cuDNN and Python support
FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git wget curl ffmpeg libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
ENV PATH="/opt/conda/bin:$PATH"
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    conda clean -afy

# Clone WanGP repository
WORKDIR /app
RUN git clone https://github.com/deepbeepmeep/Wan2GP.git .
RUN conda create -n wan2gp python=3.10.9 -y

# Activate environment and install dependencies
SHELL ["conda", "run", "-n", "wan2gp", "/bin/bash", "-c"]
RUN pip install torch==2.7.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu124
RUN pip install -r requirements.txt

# Expose default web interface port (Gradio or Streamlit)
EXPOSE 7860

# Default command: start text-to-video
CMD ["conda", "run", "-n", "wan2gp", "python", "wgp.py"]
