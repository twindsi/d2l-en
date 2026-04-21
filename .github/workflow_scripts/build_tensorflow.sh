#!/bin/bash
# Build script for TensorFlow framework version of d2l-en
# This script installs dependencies and builds the TensorFlow variant of the book

set -e

echo "========================================"
echo "Building d2l-en (TensorFlow framework)"
echo "========================================"

# Activate conda environment if available
if [ -n "$CONDA_DEFAULT_ENV" ]; then
    echo "Using conda environment: $CONDA_DEFAULT_ENV"
fi

# Install core Python dependencies
echo "Installing Python dependencies..."
pip install awscli
pip install "tensorflow>=2.9.0,<2.12.0"
pip install "tensorflow-datasets>=4.6.0"
pip install "tensorflow-probability>=0.17.0"

# Install d2l package in development mode
echo "Installing d2l package..."
pip install -e ".[tf]"

# Verify TensorFlow installation
echo "Verifying TensorFlow installation..."
python -c "import tensorflow as tf; print('TensorFlow version:', tf.__version__)"

# Set environment variables for TensorFlow build
export FRAMEWORK="tensorflow"
export TF_CPP_MIN_LOG_LEVEL=2
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}

# Install additional build dependencies
echo "Installing build dependencies..."
pip install sphinx
pip install sphinxcontrib-svg2pdfconverter
pip install "git+https://github.com/d2l-ai/d2lbook"

# Configure d2lbook for TensorFlow
echo "Configuring d2lbook for TensorFlow..."
if [ -f "config.ini" ]; then
    echo "Found config.ini"
else
    echo "Warning: config.ini not found, using defaults"
fi

# Run notebook execution for TensorFlow chapters
echo "Executing notebooks..."
d2lbook build eval --tab tensorflow

# Build HTML output
echo "Building HTML documentation..."
d2lbook build html --tab tensorflow

# Check if build artifacts exist
if [ -d "_build/html" ]; then
    echo "HTML build successful: _build/html/"
    echo "Total files: $(find _build/html -type f | wc -l)"
else
    echo "ERROR: HTML build directory not found!"
    exit 1
fi

# Package build artifacts for upload
echo "Packaging artifacts..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARTIFACT_NAME="d2l-tensorflow-${TIMESTAMP}.tar.gz"
tar -czf "${ARTIFACT_NAME}" -C _build html
echo "Artifact created: ${ARTIFACT_NAME}"

echo "========================================"
echo "TensorFlow build completed successfully!"
echo "========================================"
