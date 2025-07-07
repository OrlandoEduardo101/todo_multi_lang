# Etapa única (build + execução na mesma imagem)
FROM golang:1.24.3

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . .

RUN go build -o todo-api .

EXPOSE 3000

CMD ["./todo-api"]
