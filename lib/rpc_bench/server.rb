module RPCBench
  class Server
    def initialize(opts)
      case opts[:mode]
      when 'stomp'
        @driver = Stomp::Server.new opts
      else
        raise RuntimeError.new("failed to initialize driver of '#{opts[:mode]}'")
      end

      @driver.set_handler self
    end

    def run
      @driver.run
    end

    def callback(v)
      "reply: #{v}"
    end
  end
end
