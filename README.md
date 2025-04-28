# AMSET Installation Guide on Ubuntu 16.04

This guide provides step-by-step instructions for installing AMSET and its dependencies on Ubuntu 16.04.

## Prerequisites

- Linux operating system
- Root access or sudo privileges

## Installation Steps

### 1. Install Required Libraries

First, install the necessary system libraries:

```bash
apt-get install cmake fftw3-dev
```

### 2. Install Miniconda

Download and install Miniconda with Python 3.10.16:

```bash
./Miniconda3-py310_25.1.1-0-Linux-x86_64.sh
```

### 3. Initialize Conda Environment

After installing Miniconda, initialize the base environment:

```bash
~/miniconda/bin/conda init
bash
```

### 4. Extract Required Packages

Extract the pre-packaged pip dependencies:

```bash
tar xvpf pip_16.04.tar
```

### 5. Install AMSET

Install AMSET using the extracted packages:

```bash
pip install --no-index --find-links ./pip-packages amset
```

## Verification

To verify the installation, you can run:

```bash
python -c "import amset; print(amset.__version__)"
```

## Troubleshooting

If you encounter any issues during installation:

1. Ensure all system libraries are properly installed
2. Verify that Miniconda is correctly initialized
3. Check that the pip packages were extracted successfully
4. Ensure you have the correct Python version (3.10.16)

## Support

For additional support or questions, please refer to the AMSET documentation or create an issue in the repository.