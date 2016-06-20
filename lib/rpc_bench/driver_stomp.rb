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
        conn = ::Stomp::Connection.open('guest', 'guest', @opts[:host], @opts[:port])
        (1..count).each do |x|
          conn.publish(RPCBench::Stomp::QNAME, "#{data}-#{x}", {
            'reply-to' => TEMP_QNAME
          })
        end
        (1..count).each do |_|
          conn.receive.body
        end
  
        conn.disconnect
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
          reply = @handler.callback(msg.body)
  
          conn.publish(msg.headers['reply-to'], reply)
        end
      end
    end
  end
end
