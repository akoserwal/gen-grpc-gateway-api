#!/bin/bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if golang is installed
if command_exists go; then
    echo "go is already installed."
	echo `go version`
else
    echo "go is not installed. Please install go"
	exit 1
fi

# Check if protoc is installed
if command_exists protoc; then
    echo "protoc is already installed."
	echo `protoc --version`
else
    echo "protoc is not installed. Please install protoc"
	exit 1
fi

# Function to check for errors
error_check() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Get project name from user
read -p "Enter project name: " PROJECT_NAME

# Check if project name is empty
if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: Please provide a project name."
  exit 1
fi

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Get project name from user
read -p "Enter domain name: " DOMAIN_NAME

# Check if project name is empty
if [[ -z "$DOMAIN_NAME" ]]; then
  echo "Error: Please provide a domain name."
  exit 1
fi

# Initialize go module
go mod init "github.com/$DOMAIN_NAME/$PROJECT_NAME"

# Prompt user for service name
read -p "Enter service name (e.g., Greeter): " SERVICE_NAME

# Using `tr`
SERVICE_NAME_LOWER_TR=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]')
echo "Lowercase using tr: $SERVICE_NAME_LOWER_TR"
# Create proto directory
mkdir -p proto/$SERVICE_NAME_LOWER_TR

# Create proto file
echo "syntax = \"proto3\";
option go_package = \"github.com/$DOMAIN_NAME/$PROJECT_NAME/$SERVICE_NAME_LOWER_TR\";

import \"google/api/annotations.proto\";

service $SERVICE_NAME {
  rpc SayHello (HelloRequest) returns (HelloResponse) {
    option (google.api.http) = {
      get: \"/v1/hello\",
    };
  }
}

message HelloRequest {
  string name = 1;
}

message HelloResponse {
  string message = 1;
}
" > proto/$SERVICE_NAME_LOWER_TR/$SERVICE_NAME_LOWER_TR.proto

# Install grpc-gateway plugin
mkdir -p proto/google/api
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
go get google.golang.org/grpc
curl -L https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/annotations.proto -o proto/google/api/annotations.proto
curl -L https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/http.proto -o proto/google/api/http.proto

mkdir -p protogen/golang

# Define the content of the Makefile
makefile_content="
PROTO_SRC_DIR=proto
PROTO_DEST_DIR=protogen/golang

server:
	go run cmd/server/main.go
.PHONY: server

client:
	go run cmd/client/main.go
.PHONY: client

.PHONY: all proto

all: proto

proto:
\tcd \$(PROTO_SRC_DIR) && protoc --go_out=../\$(PROTO_DEST_DIR) --go_opt=paths=source_relative \\
\t--go-grpc_out=../\$(PROTO_DEST_DIR) --go-grpc_opt=paths=source_relative \\
\t--grpc-gateway_out=../\$(PROTO_DEST_DIR) --grpc-gateway_opt paths=source_relative \\
\t--grpc-gateway_opt generate_unbound_methods=true \\
\t./**/*.proto
"

# Write the content to the Makefile
echo -e "$makefile_content" > Makefile


make proto

mkdir -p cmd/server internal
touch cmd/server/main.go internal/${SERVICE_NAME_LOWER_TR}service.go


# Create service file
echo "package internal

import (
 \"context\"
 \"log\"
	\"github.com/$DOMAIN_NAME/$PROJECT_NAME/protogen/golang/$SERVICE_NAME_LOWER_TR\"
)

type ${SERVICE_NAME}Service struct {
	${SERVICE_NAME_LOWER_TR}.Unimplemented${SERVICE_NAME}Server
}

func New${SERVICE_NAME}Service() ${SERVICE_NAME}Service {
	return ${SERVICE_NAME}Service{}
}

func (o *${SERVICE_NAME}Service) SayHello(_ context.Context, h *${SERVICE_NAME_LOWER_TR}.HelloRequest) (*${SERVICE_NAME_LOWER_TR}.HelloResponse, error) {
	log.Printf(\"Received a hello request %v\", h.Name)
	return &${SERVICE_NAME_LOWER_TR}.HelloResponse{Message: \"Hello\"}, nil
}


" > internal/${SERVICE_NAME_LOWER_TR}service.go

echo "package main

import (
	\"log\"
	\"net\"
	\"github.com/$DOMAIN_NAME/$PROJECT_NAME/internal\"
	\"github.com/$DOMAIN_NAME/$PROJECT_NAME/protogen/golang/$SERVICE_NAME_LOWER_TR\"
    \"google.golang.org/grpc\"
	\"google.golang.org/grpc/reflection\"
)

func main() {
	const addr = \"0.0.0.0:50051\"
	// create a TCP listener on the specified port
	listener, err := net.Listen(\"tcp\", addr)
	if err != nil {
		log.Fatalf(\"failed to listen: %v\", err)
	}
	// create a gRPC server instance
	server := grpc.NewServer()
	// create a service instance with a reference to the db
	reflection.Register(server)
	
	${SERVICE_NAME_LOWER_TR}Service := internal.New${SERVICE_NAME}Service()
	// register the service with the grpc server

	${SERVICE_NAME_LOWER_TR}.Register${SERVICE_NAME}Server(server, &${SERVICE_NAME_LOWER_TR}Service)
	// start listening to requests
	
    log.Printf(\"server listening at %v\", listener.Addr())
	if err = server.Serve(listener); err != nil {
		log.Fatalf(\"failed to serve: %v\", err)
	}
}

" > cmd/server/main.go

mkdir cmd/client
touch cmd/client/main.go

echo "package main

import (
	\"context\"
	\"fmt\"
	\"log\"
	\"net/http\"
    \"github.com/grpc-ecosystem/grpc-gateway/v2/runtime\"
	\"github.com/$DOMAIN_NAME/$PROJECT_NAME/protogen/golang/$SERVICE_NAME_LOWER_TR\"
    \"google.golang.org/grpc\"
    \"google.golang.org/grpc/credentials/insecure\"
)

func main() {
	${SERVICE_NAME_LOWER_TR}ServiceAddr := \"localhost:50051\"
    conn, err := grpc.NewClient(${SERVICE_NAME_LOWER_TR}ServiceAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf(\"could not connect to service: %v\", err)
	}
	defer conn.Close()
    mux := runtime.NewServeMux()
	if err = ${SERVICE_NAME_LOWER_TR}.Register${SERVICE_NAME}Handler(context.Background(), mux, conn); err != nil {
		log.Fatalf(\"failed to register the server: %v\", err)
	}
    addr := \"0.0.0.0:8080\"
	fmt.Println(\"API gateway server is running on \" + addr)
	if err = http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(\"gateway server closed abruptly: \", err)
	}
}

" > cmd/client/main.go

error_check "Failed to generate code"

# Clean up temporary files (optional)
# rm -rf *.pb.go *.gw.go

echo "Project '$PROJECT_NAME' created with grpc-gateway"
echo "cd $PROJECT_NAME"
echo "make server"
echo "make client"
echo "curl '0.0.0.0:8080/v1/hello'"
