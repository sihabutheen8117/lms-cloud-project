# # Use Nginx to serve the static HTML application
# FROM nginx:alpine

# # Copy the HTML file to Nginx's default directory
# COPY index.html /usr/share/nginx/html/index.html

# # Copy custom nginx configuration (optional)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# # Expose port 80
# EXPOSE 80

# # Start Nginx
# CMD ["nginx", "-g", "daemon off;"]

FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80

