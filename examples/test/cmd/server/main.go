package main

import (
	"log"
	"net"
	"github.com/akoserwal/test/internal"
	"github.com/akoserwal/test/protogen/golang/hello"
    "google.golang.org/grpc"
)

func main() {
	const addr = "0.0.0.0:50051"
	// create a TCP listener on the specified port
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	// create a gRPC server instance
	server := grpc.NewServer()
	// create a service instance with a reference to the db
	
	helloService := internal.NewHelloService()
	// register the service with the grpc server

	hello.RegisterHelloServer(server, &helloService)
	// start listening to requests
	
    log.Printf("server listening at %v", listener.Addr())
	if err = server.Serve(listener); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}


