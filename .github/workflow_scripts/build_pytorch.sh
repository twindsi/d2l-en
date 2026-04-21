#!/bin/bash
# Build script for PyTorch version of d2l-en
# This script builds the book using the PyTorch framework

set -e

echo "========================================"
echo "Building d2l-en with PyTorch backend"
echo "========================================"

# Source environment variables if available
if [ -f ".github/actions/setup_env_vars/action.yml" ]; then
    echo "Environment setup found"
fi

# Check Python version
PYTHON_VERSION=$(python --version 2>&1)
echo "Using: $PYTHON_VERSION"

# Check PyTorch installation
echo "Checking PyTorch installation..."
python -c "import torch; print(f'PyTorch version: {torch.__version__}')" || {
    echo "ERROR: PyTorch is not installed. Please install it first."
    exit 1
}

# Check for CUDA availability
python -c "
import torch
if torch.cuda.is_available():
    print(f'CUDA available: {torch.cuda.get_device_name(0)}')
    print(f'CUDA version: {torch.version.cuda}')
else:
    print('CUDA not available, using CPU')
"

# Install d2l package in development mode
echo "Installing d2l package..."
pip install -e . --quiet

# Verify d2l installation
python -c "import d2l; print(f'd2l version: {d2l.__version__}')" || {
    echo "ERROR: d2l package installation failed."
    exit 1
}

# Set the framework environment variable
export FRAMEWORK=pytorch

# Run notebook execution
echo "Starting notebook build for PyTorch..."
if [ -z "$NUM_WORKERS" ]; then
    NUM_WORKERS=4
fi
echo "Using $NUM_WORKERS workers for parallel build"

# Build the notebooks
python utils/build_notebooks.py \
    --framework pytorch \
    --num-workers "$NUM_WORKERS" \
    --timeout 1200 || {
    echo "ERROR: Notebook build failed."
    exit 1
}

# Build HTML output
echo "Building HTML documentation..."
bash .github/workflow_scripts/build_html.sh

echo "========================================"
echo "PyTorch build completed successfully!"
echo "========================================"
