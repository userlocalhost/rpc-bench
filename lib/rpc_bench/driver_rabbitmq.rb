require 'bunny'

module RPCBench
  class RabbitMQ < Driver
    QNAME = 'rpc_queue'

    def initialize opts
      super opts

      @conn = Bunny.new(host: opts[:host], port: opts[:port])
      @conn.start

      @ch = @conn.create_channel
      @exchange = @ch.default_exchange

      @reply_queue = @ch.queue("", :exclusive => true)

      @reply_queue.subscribe do |_, _, data|
        @handler.callback(data)
      end
    end

    def close
      @ch.close
      @conn.close
    end

    def send_request(data)
      @exchange.publish(data.to_s, :routing_key => QNAME, :reply_to => @reply_queue.name)
    end
  end
end
