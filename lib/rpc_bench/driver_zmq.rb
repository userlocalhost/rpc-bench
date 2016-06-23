require 'ffi-rzmq'

module RPCBench
  module ZeroMQ
    class Base < Driver
      def initialize opts
        @opts = opts
        @context = ZMQ::Context.new
      end
    end
    class Client < Base
      def initialize opts
        super opts
      end
  
      def send_request data, count
        sock = @context.socket(ZMQ::REQ)
        sock.connect("tcp://#{@opts[:host]}:#{@opts[:port]}")
  
        results = []
        (1..count).each do |_|
          # sending request
          sock.send_string data.to_s
  
          # receiving reply
          reply = ''
          sock.recv_string(reply)

          results << reply.slice(/[0-9]+/).to_i
        end
        sock.close

        results
      end
  
      def close
        @context.terminate
      end
    end
    class Server < Base
      def initialize opts
        super opts
      end

      def run
        sock = @context.socket(ZMQ::REP)
        sock.bind("tcp://*:#{@opts[:port]}")

        loop do
          request = ''

          sock.recv_string(request)

          data = request.inspect.slice(/[0-9]+/).to_i

          # Send reply back to client
          sock.send_string(@handler.callback(data).to_s)
        end
      end
    end
  end
end
