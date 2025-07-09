#!/bin/bash
# web-server-setup.sh

# Update system packages
sudo apt-get update -y

# Install nginx
sudo apt-get install nginx -y

# Create a simple index page
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Web Hosting Solution</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background-color: #f4f4f4; padding: 20px; text-align: center; }
        .content { padding: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Automated Web Hosting Solution</h1>
            <p>Server: $(hostname)</p>
            <p>Environment: \${environment}</p>
        </div>
        <div class="content">
            <h2>Welcome!</h2>
            <p>This web server was automatically provisioned using Infrastructure as Code (IAC) with Terraform.</p>
            <p>Load balanced and highly available across multiple instances.</p>
        </div>
    </div>
</body>
</html>
EOF

# Create health check endpoint
sudo tee /var/www/html/health > /dev/null <<EOF
OK
EOF

# Configure nginx
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure firewall
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

echo "Web server setup completed successfully!"
