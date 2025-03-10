# Stage 1: Build the React App
FROM node:20 AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first for better caching
COPY package*.json ./

# Install dependencies with --legacy-peer-deps flag to resolve dependency conflicts
RUN npm install --omit=dev --legacy-peer-deps

# Copy the rest of the app source code
COPY . .

# Install missing Babel plugin inside the container (if needed)
RUN npm install @babel/plugin-proposal-private-property-in-object --save-dev

# Build the React.js app for production
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy the built React files from the previous stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port Nginx is running on
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]

