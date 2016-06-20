require 'bunny'

module RPCBench
  module RabbitMQ
    class Base < Driver
      QNAME = 'rpc_queue'

      def initialize opts
        @conn = Bunny.new(host: opts[:host], port: opts[:port])
        @conn.start
  
        @ch = @conn.create_channel
        @exchange = @ch.default_exchange
      end
  
      def close
        @ch.close
        @conn.close
      end
    end

    class Client < Base
      def initialize opts
        super opts
  
        @reply_queue = @ch.queue("", :exclusive => true)
  
        @reply_queue.subscribe do |_, _, data|
          @handler.callback(data)
        end
      end
  
      def send_request data, count
        (1..count).each do |_|
          @exchange.publish(data.to_s, :routing_key => QNAME, :reply_to => @reply_queue.name)
        end
      end
    end
    class Server < Base
      def initialize opts
        super opts

        @queue = @ch.queue QNAME
      end

      def run
        @queue.subscribe(:block => true) do |_, attr, data|
          resp = @handler.callback(data)

          @exchange.publish(resp, :routing_key => attr.reply_to, :correlation_id => attr.correlation_id)
        end
      end
    end
  end
end
