require 'stomp'

module RPCBench
  class Stomp < Driver
    QNAME = '/queue/rpc-bench'
    TEMP_QNAME = '/temp-queue/rpc-bench'
    def initialize opts
      @opts = opts
    end

    def send_request data, count
      conn = ::Stomp::Connection.open('guest', 'guest', @opts[:host], @opts[:port])
      (1..count).each do |_|
        conn.publish(QNAME, data.to_s, {
          'reply-to' => TEMP_QNAME
        })
        conn.receive
      end
      conn.disconnect
    end
  end
end
