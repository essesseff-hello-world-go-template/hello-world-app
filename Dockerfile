# Build stage
FROM golang:1.27-alpine AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o hello-world .

# Runtime stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates

# Create non-root user with UID 1000
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -D appuser

WORKDIR /app
COPY --from=builder --chown=1000:1000 /app/hello-world .

# Switch to non-root user
USER 1000

EXPOSE 8080
CMD ["./hello-world"]
