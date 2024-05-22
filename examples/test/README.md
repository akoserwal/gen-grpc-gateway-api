# Test project generate by gen-grpc-gateway-api script

## Run the grpc server
```
cd test
make server
```
expose the service: http://0.0.0.0:50051

## Run the client (grpc-gateway)

```
cd test
make client
```
 expose the rest endpoint: http://0.0.0.0:8080

Test the REST endpoint
```curl '0.0.0.0:8080/v1/hello' ```

# Post updating hello.proto
Run
`make proto`