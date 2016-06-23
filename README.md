# RPCBench
RPCBench is a simple benchmark tool for RabbitMQ(AMQP, STOMP), ZeroMQ, gRPC.
For benchmarking RPC using these middleware, RPCBench using following library.

## Installation
You have to install some libraries which client of RPCBench uses.
This explanes the procedure to install them on Ubuntu14.04.

### Install some packages
Some packages is needed to prepare following environment (e.g. building `libzmq` library).
```
$ sudo apt-get install protobuf-compiler autoconf rabbitmq-server libtool
```

### for gRPC
Here is a procedure to install Ruby gems to benchmark gRPC.
```
$ git clone https://github.com/grpc/grpc.git
$ cd grpc
$ bundle install
```

### for ZeroMQ
You have to install `libzmq` which is the library of ZeroMQ.
In this document, I'll show the procedure to install it from source code.
```
$ git clone git@github.com:zeromq/libzmq.git
$ autoreconf -i
$ ./configure; make
$ sudo make install
```

### for RabbitMQ (stomp)
To use rabbitmq-stomp plugin, you have to enable it from `rabbitmq-plugins` command like following and install Ruby gem of STOMP client.
```
$ sudo rabbitmq-plugins enable rabbitmq_stomp
$ gem install stomp
```

### RPCBench
Now, you have finished groundwork to benchmark using RPCBench.
Here is a way to install it.

```
$ gem install rpc_bench
```

## Usage

### Server
Here is the usage of server.
```
Usage: rpc_bench_server [options]
    -m, --mode m                     specify benchmark mode {rabbitmq|rabbitmq-stomp|newtmq|zeromq|grpc} [default: rabbitmq]
    -s, --server s                   specify server to send request
    -p, --port p                     specify port number on which server listens
```

When you want to benchmark ZeroMQ, you execute `rpc_bench_server` command with `-m zeromq` which means 'ZeroMQ server mode'. And the parameter of `-p` means port number to listen.
```
$ rpc_bench_server -m zeromq -p 20000
```

### Client
Here is the usage of client.
```
Usage: rpc_bench_client [options]
    -m, --mode m                     specify benchmark mode {rabbitmq|rabbitmq-stomp|newtmq|zeromq|grpc} [default: rabbitmq]
    -s, --server s                   specify server to send request
    -p, --port p                     specify port number on which server listens
    -c, --concurrency c              specify concurrent level [default: 10]
    -n, --number n                   specify request number per thread [default: 100]
```

When you want to benchmark ZeroMQ, you do command `rpc_benchmark_client` command with `-m zeromq` in the same way.
Additionally, you can take some parameters that is `-c, --concurrency` and `-n, --number`.
The `--concurrency` means the number of threads to execute the processing to send request to server. And the `--number` means the number of requests to send request per thread.
```
$ rpc_bench_client -m zeromq -p 20000 -c 16 -n 50000
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
