module RPCBench
  class Client
    def initialize(opts)
      @bench_conc = opts[:conc]
      @bench_num = opts[:num]

      case opts[:mode]
      when 'rabbitmq'
        @driver = RabbitMQ::Client.new opts
      when 'grpc'
        @driver = GRPC::Client.new opts
      when 'zeromq'
        @driver = ZeroMQ::Client.new opts
      when 'stomp'
        @driver = Stomp::Client.new opts
      else
        raise RuntimeError.new("failed to initialize driver of '#{opts[:mode]}'")
      end
    end

    def validate? results
      results.all? {|x| x == 2}
    end

    def run
      t_start = Time.now

      threads = []
      (1..@bench_conc).each do |x|
        threads << Thread.new do
          @driver.send(1, @bench_num)
        end
      end

      results = threads.map(&:value).flatten
      unless(validate? results)
        puts "[error] failed to get accurate result"
      end

      @driver.close

      t_end = Time.now

      puts "Time: #{t_end - t_start}"
    end
  end
end
