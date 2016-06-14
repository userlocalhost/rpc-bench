module RPCBench
  class Client
    def initialize(opts)
      @bench_conc = opts[:conc]
      @bench_num = opts[:num]

      @resp_count = 0

      case opts[:mode]
      when 'rabbitmq'
        @driver = RabbitMQ.new opts
      else
        raise RuntimeError.new("failed to initialize driver of '#{opts[:mode]}'")
      end

      @driver.set_handler self
    end

    def run
      (1..@bench_conc).each do
        Thread.new do
          (1..@bench_num).each {|n| @driver.send(1)}
        end
      end

      while(! finished?) do
        # nop
      end

      @driver.close
    end

    def callback(msg)
      @resp_count += 1
      puts "[RPCBench::Client] count: #{@resp_count}"
    end

    private
    def finished?
      @resp_count >= req_total
    end

    def req_total
      @req_total ||= @bench_conc * @bench_num
    end
  end
end
