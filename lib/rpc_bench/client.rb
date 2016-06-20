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
      when 'stomp'
        @driver = Stomp::Client.new opts
      else
        raise RuntimeError.new("failed to initialize driver of '#{opts[:mode]}'")
      end

      @driver.set_handler self
    end

    def run
      t_start = Time.now

      threads = []
      (1..@bench_conc).each do |x|
        threads << Thread.new do
          @driver.send(x, @bench_num)
        end
      end
      threads.each(&:join)

      while(! finished?) do
        # nop
      end

      puts "Time: #{Time.now - t_start}"

      @driver.close
    end

    def callback(msg)
      @resp_count += 1
    end

    private
    def finished?
      if @driver.instance_of? RabbitMQ
        @resp_count >= req_total
      else
        # other drivers get response synchronously
        true
      end
    end

    def req_total
      @req_total ||= @bench_conc * @bench_num
    end
  end
end
