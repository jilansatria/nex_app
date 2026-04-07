FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

WORKDIR /app

# Copy dependency definition to leverage cache
COPY pubspec.* ./
RUN flutter pub get

# Copy source code
COPY . .

# Build for web
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built artifacts
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
