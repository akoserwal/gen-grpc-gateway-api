package internal

import (
 "context"
 "log"
	"github.com/akoserwal/test/protogen/golang/hello"
)

type HelloService struct {
	hello.UnimplementedHelloServer
}

func NewHelloService() HelloService {
	return HelloService{}
}

func (o *HelloService) SayHello(_ context.Context, h *hello.HelloRequest) (*hello.HelloResponse, error) {
	log.Printf("Received a hello request %v", h.Name)
	return &hello.HelloResponse{Message: "Hello"}, nil
}



