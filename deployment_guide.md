# Deployment Guide: Gunicorn and Nginx Setup

This guide explains how to deploy Dash and Django applications using Gunicorn as the WSGI server and Nginx as a reverse proxy.

## Table of Contents
- [Gunicorn Setup](#gunicorn-setup)
- [Dash Application Deployment](#dash-application-deployment)
- [Django Application Deployment](#django-application-deployment)
- [Nginx Configuration](#nginx-configuration)
- [Example Configurations](#example-configurations)

## Gunicorn Setup

Gunicorn is a Python WSGI HTTP Server for UNIX. It's a pre-fork worker model, which means it creates multiple worker processes to handle requests.

### Installation
```bash
pip install gunicorn
```

## Dash Application Deployment

### wsgi.py file for Dash App
```python
# wsgi.py
from app import app

server = app.server

if __name__ == '__main__':
    app.run(debug=True)
```

### Running with Gunicorn
```bash
gunicorn wsgi:server -b 0.0.0.0:8050 -w 4 -t 2
```
- `app:server` - path to the Dash application (app.py) and the server object
- `-b 0.0.0.0:8050` - bind to all interfaces on port 8050
- `-w 4` - use 4 worker processes
- `-t 2` - use 2 threads

## Django Application Deployment

### Basic Django Project Structure
```
myproject/
    ├── manage.py
    └── myproject/
        ├── __init__.py
        ├── settings.py
        ├── urls.py
        └── wsgi.py
```

### Running with Gunicorn
```bash
gunicorn myproject.wsgi:application -b 0.0.0.0:8000 -w 4
```
- `myproject.wsgi:application` - path to the WSGI application
- `-b 0.0.0.0:8000` - bind to all interfaces on port 8000
- `-w 4` - use 4 worker processes

## Nginx Configuration

Nginx acts as a reverse proxy, handling static files and forwarding requests to Gunicorn.

### Installation
```bash
sudo apt-get update
sudo apt-get install nginx
```

### Example Nginx Configuration
```nginx
# /etc/nginx/sites-available/myapp

# Dash Application
server {
    listen 80;
    server_name dash.example.com;

    location / {
        proxy_pass http://127.0.0.1:8050;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Django Application
server {
    listen 80;
    server_name django.example.com;

    location /static/ {
        alias /path/to/your/static/;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Example Configurations

### 1. Dash Application with Gunicorn
```bash
# Start Dash app with Gunicorn
gunicorn wsgi:server -b 0.0.0.0:8050 -w 4 --timeout 120
```

### 2. Django Application with Gunicorn
```bash
# Start Django app with Gunicorn
gunicorn myproject.wsgi:application -b 0.0.0.0:8000 -w 4 --timeout 120
```

### 3. Systemd Service Files

#### Dash Service
```ini
# /etc/systemd/system/dash.service
[Unit]
Description=Gunicorn instance to serve Dash application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/dash/app
Environment="PATH=/path/to/venv/bin"
ExecStart=/path/to/venv/bin/gunicorn app:server -b 0.0.0.0:8050 -w 4

[Install]
WantedBy=multi-user.target
```

#### Django Service
```ini
# /etc/systemd/system/django.service
[Unit]
Description=Gunicorn instance to serve Django application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/django/project
Environment="PATH=/path/to/venv/bin"
ExecStart=/path/to/venv/bin/gunicorn myproject.wsgi:application -b 0.0.0.0:8000 -w 4

[Install]
WantedBy=multi-user.target
```

### 4. Complete Nginx Configuration with SSL
```nginx
# /etc/nginx/sites-available/myapp
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # Dash Application
    location /dash/ {
        proxy_pass http://127.0.0.1:8050/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Django Application
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /path/to/your/static/;
    }
}
```

## Best Practices

1. **Worker Configuration**
   - Number of workers = (2 x number_of_CPU_cores) + 1
   - Example: For a 4-core CPU, use 9 workers

2. **Timeout Settings**
   - Set appropriate timeout values for long-running requests
   - Example: `--timeout 120` for 2-minute timeout

3. **Security**
   - Always use SSL/TLS in production
   - Keep Gunicorn behind Nginx
   - Set appropriate file permissions

4. **Monitoring**
   - Use logging for both Gunicorn and Nginx
   - Monitor worker processes
   - Set up error reporting

## Troubleshooting

1. **Connection Issues**
   - Check if ports are open
   - Verify firewall settings
   - Check Nginx error logs

2. **Performance Issues**
   - Monitor worker processes
   - Check system resources
   - Review Nginx access logs

3. **Static Files**
   - Ensure correct file permissions
   - Verify static file paths in Nginx config
   - Check Django static files collection 