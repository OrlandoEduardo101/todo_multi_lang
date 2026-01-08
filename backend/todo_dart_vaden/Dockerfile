FROM dart:3.10.4 AS build

WORKDIR /app

# Resolve app dependencies
COPY pubspec.* ./
RUN dart pub get

# Copy source
COPY . .
RUN dart pub get --offline

# Generate code (Drift, etc.)
RUN dart run build_runner build --delete-conflicting-outputs

# Compile to native executable
RUN dart compile exe bin/server.dart -o bin/server

# Runtime image
FROM scratch
WORKDIR /app
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/
COPY --from=build /app/application.yaml /app/
EXPOSE 8080
CMD ["./server"]
