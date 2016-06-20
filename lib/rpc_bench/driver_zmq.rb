require 'ffi-rzmq'

module RPCBench
  class ZeroMQ < Driver
    def initialize opts
      @opts = opts
      @context = ZMQ::Context.new
    end

    def send_request data, count
      sock = @context.socket(ZMQ::REQ)
      sock.connect("tcp://#{@opts[:host]}:#{@opts[:port]}")

      (1..count).each do |_|
        # sending request
        sock.send_string data.to_s

        # receiving reply
        reply = ''
        sock.recv_string reply
      end

      sock.close
    end

    def close
      @context.terminate
    end
  end
end
