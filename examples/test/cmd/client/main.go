package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
    "github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"github.com/akoserwal/test/protogen/golang/hello"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

func main() {
	helloServiceAddr := "localhost:50051"
    conn, err := grpc.NewClient(helloServiceAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("could not connect to service: %v", err)
	}
	defer conn.Close()
    mux := runtime.NewServeMux()
	if err = hello.RegisterHelloHandler(context.Background(), mux, conn); err != nil {
		log.Fatalf("failed to register the server: %v", err)
	}
    addr := "0.0.0.0:8080"
	fmt.Println("API gateway server is running on " + addr)
	if err = http.ListenAndServe(addr, mux); err != nil {
		log.Fatal("gateway server closed abruptly: ", err)
	}
}


