
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
	cd $(PROTO_SRC_DIR) && protoc --go_out=../$(PROTO_DEST_DIR) --go_opt=paths=source_relative \
	--go-grpc_out=../$(PROTO_DEST_DIR) --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=../$(PROTO_DEST_DIR) --grpc-gateway_opt paths=source_relative \
	--grpc-gateway_opt generate_unbound_methods=true \
	./**/*.proto

