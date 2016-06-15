require 'rubygems'
require 'ffi-rzmq'

module RPCBench
  class ZeroMQ < Driver
    def initialize opts
      @context = ZMQ::Context.new
      @sock = @context.socket(ZMQ::REQ)
      @sock.connect("tcp://#{opts[:host]}:#{opts[:port]}")
    end

    def send_request data
      # sending request
      @sock.send_string data.to_s

      # receiving reply
      reply = ''
      @sock.recv_string reply

      @handler.callback reply
    end

    def close
      @sock.close
    end
  end
end
