module RPCBench
  class Client
    def initialize(opts)
      @bench_conc = opts[:conc]
      @bench_num = opts[:num]

      @resp_count = 0

      case opts[:mode]
      when 'rabbitmq'
        @driver = RabbitMQ.new opts
      when 'grpc'
        @driver = GRPC.new opts
      when 'zeromq'
        @driver = ZeroMQ.new opts
      else
        raise RuntimeError.new("failed to initialize driver of '#{opts[:mode]}'")
      end

      @driver.set_handler self
    end

    def run
      threads = []
      (1..@bench_conc).each do
        threads << Thread.new do
          (1..@bench_num).each {|n| @driver.send(1)}
        end
      end
      threads.each(&:join)

      while(! finished?) do
        # nop
      end

      @driver.close
    end

    def callback(msg)
      @resp_count += 1
      puts "[Client] (callback) #{msg}"
    end

    private
    def finished?
      if @driver.instance_of? GRPC
        # GRPC framework get response synchronously
        true
      else
        @resp_count >= req_total
      end
    end

    def req_total
      @req_total ||= @bench_conc * @bench_num
    end
  end
end
