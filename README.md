# gen-grpc-gateway-api
A shell script to generate a golang project uses grpc-gateway and proto to expose a sample api.

Using the gen-grpc-gateway-api generator you can quickly get start with [grpc-gateway](https://grpc-ecosystem.github.io/grpc-gateway/#getting-started)

## Prerequisite
* [golang](https://go.dev/doc/install)
* [Install protoc](https://github.com/protocolbuffers/protobuf/releases)


## Generate project
```
./gen-grpc.sh
```
It will prompt for `project name`, `domain name` and `service name for the proto`

## Example
```
Enter project name: test
Enter domain name: akoserwal
go: creating new go.mod: module github.com/akoserwal/test
Enter service name (e.g., Greeter): Hello
...

Project 'test' created with grpc-gateway
cd test
make server
make client
curl '0.0.0.0:8080/v1/hello'
```

## Generate project structure

```
 test git:(main) ✗ tree
.
├── Makefile
├── cmd
│   ├── client
│   │   └── main.go
│   └── server
│       └── main.go
├── go.mod
├── go.sum
├── internal
│   └── helloservice.go # sample service
├── proto
│   ├── google
│   │   └── api
│   │       ├── annotations.proto
│   │       └── http.proto
│   └── hello
│       └── hello.proto # API definition
└── protogen
    └── golang
        └── hello
            ├── hello.pb.go
            ├── hello.pb.gw.go
            └── hello_grpc.pb.go

```