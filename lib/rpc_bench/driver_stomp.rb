require 'stomp'

module RPCBench
  module Stomp
    QNAME = '/queue/rpc-bench'

    class Client < Driver
      TEMP_QNAME = '/temp-queue/rpc-bench'
      def initialize opts
        @opts = opts
      end
  
      def send_request data, count
        results = []

        conn = ::Stomp::Connection.open('guest', 'guest', @opts[:host], @opts[:port])
        (1..count).each do |x|
          conn.publish(RPCBench::Stomp::QNAME, data.to_s, {
            'reply-to' => TEMP_QNAME
          })
        end
        (1..count).each do |_|
          results << conn.receive.body.slice(/[0-9]*/).to_i
        end
        conn.disconnect

        results
      end
    end
    class Server < Driver
      def initialize opts
        @opts = opts
      end

      def run
        conn = ::Stomp::Connection.open('guest', 'guest', @opts[:host], @opts[:port])

        conn.subscribe RPCBench::Stomp::QNAME
        loop do
          msg = conn.receive
          reply = @handler.callback(msg.body.to_i)
  
          conn.publish(msg.headers['reply-to'], reply.to_s)
        end
      end
    end
  end
end
