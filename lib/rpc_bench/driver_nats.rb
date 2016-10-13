require 'nats/client'

module RPCBench
  module NATS
    QNAME = 'nats-bench'

    class NATSDriver < Driver
      def initialize opts
        @host = opts[:host] ? opts[:host] : 'localhost'
        @port = opts[:port] ? opts[:port] : 4222
      end
    end

    class Client < NATSDriver
      def initialize opts
        super opts
      end

      def send_request data, count
        results = []
        ::NATS.start(:servers => ["nats://#{@host}:#{@port}"]) do
          (1..count).each do |_|
            ::NATS.request(QNAME, data) do |resp|
              results << resp.to_i

              if results.size >= count
                ::NATS.stop
              end
            end
          end
        end
        results
      end
    end
    class Server < NATSDriver
      def initialize opts
        super opts
      end

      def run
        ::NATS.start(:servers => ["nats://#{@host}:#{@port}"]) do
          ::NATS.subscribe(QNAME) do |msg, reply|
            ::NATS.publish(reply, @handler.callback(msg.to_i))
          end
        end
      end
    end
  end
end
