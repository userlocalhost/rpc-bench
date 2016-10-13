require 'nats/client'

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
      when 'nats'
        @driver = NATS::Client.new opts
      else
        raise RuntimeError.new("failed to initialize driver of '#{opts[:mode]}'")
      end
    end

    def validate? results
      results.all? {|x| x == 2}
    end

    def run
      t_start = Time.now

      # sending requests to the server and waiting until all of corresponding messages are received
      sending_and_receiving

      # get received messages which are sent by the server
      results = get_results

      unless(validate? results)
        puts "[error] failed to get accurate result"
      end

      @driver.close

      t_end = Time.now

      puts "Time: #{t_end - t_start}"
    end

    private
    def sending_and_receiving
      @pipes = []
      (1..@bench_conc).each do |x|
        pipe = create_pipe
        fork do
          write_object(@driver.send(1, @bench_num), pipe.last)
        end
        @pipes << pipe
      end
    end

    def get_results
      @pipes.map do |pipe|
        results = read_object(pipe.first)
      end.flatten
    end

    def create_pipe
      IO.pipe.map{|pipe| pipe.tap{|_| _.set_encoding("ASCII-8BIT", "ASCII-8BIT") } }
    end
    
    def write_object(obj, write)
      data = Marshal.dump(obj).gsub("\n", '\n') + "\n"
      write.write data
    end
    
    def read_object(read)
      data = read.gets
      Marshal.load(data.chomp.gsub('\n', "\n"))
    end
  end
end
