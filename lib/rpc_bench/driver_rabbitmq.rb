require 'bunny'

module RPCBench
  module RabbitMQ
    QNAME = 'rpc_queue'

    class Client < Driver
      def initialize opts
        @opts = opts
      end
  
      def send_request data, count
        results = []

        conn = Bunny.new(host: @opts[:host], port: @opts[:port])
        conn.start
  
        ch = conn.create_channel
        exchange = ch.default_exchange
  
        reply_queue = ch.queue("", :exclusive => true)
        (1..count).each do |_|
          exchange.publish(data.to_s, :routing_key => RPCBench::RabbitMQ::QNAME, :reply_to => reply_queue.name)
        end
  
        reply_queue.subscribe(:block => true) do |dinfo, _, data|
          results << data.to_i

          if results.size >= count
            dinfo.consumer.cancel
            break
          end
        end
        ch.close
        conn.close

        results
      end
    end
    class Server < Driver
      def initialize opts
        @opts = opts
      end

      def run
        conn = Bunny.new(host: @opts[:host], port: @opts[:port])
        conn.start

        ch = conn.create_channel

        queue = ch.queue RPCBench::RabbitMQ::QNAME
        exchange = ch.default_exchange
        queue.subscribe(:block => true) do |_, attr, data|
          resp = @handler.callback(data.to_i)

          exchange.publish(resp.to_s, :routing_key => attr.reply_to, :correlation_id => attr.correlation_id)
        end

        ch.close
        conn.close
      end
    end
  end
end
