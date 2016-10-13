require "optparse"

module RPCBench
  class Options
    MODE_VALUES = ['rabbitmq', 'stomp', 'zeromq', 'grpc', 'nats']

    OPT_DEFAULT = {
      :host => 'localhost',
      :port => 5672,
      :mode => 'rabbitmq',
    }
    def initialize
      def sets(key, short, long, desc)
        @opt.on(short, long, desc) {|v| @options[key] = v}
      end
      def setn(key, short, long, desc)
        @opt.on(short, long, desc) {|v| @options[key] = v.to_i}
      end

      @options = OPT_DEFAULT
      @opt = OptionParser.new
      
      sets(:mode, '-m', '--mode m',
           'specify benchmark mode {rabbitmq|stomp|newtmq|zeromq|grpc|nats} [default: rabbitmq]')
      sets(:host, '-s', '--server s',
           'specify server to send request')
      setn(:port, '-p', '--port p',
           'specify port number on which server listens')
    end

    def parse
      @opt.parse!(ARGV)

      raise OptionParser::InvalidOption.new('validation failed') unless validated?

      @options
    end

    def usage
      @opt.help
    end

    private
    def validated?
      ret = true

      ret &= MODE_VALUES.include? @options[:mode]
      ret &= @options[:conc].is_a? Integer
      ret &= @options[:num].is_a? Integer
    end
  end

  class ServerOptions < Options
    def initialize
      super
    end
  end
  class ClientOptions < Options
    OPT_DEFAULT.merge!({
      :conc => 10,
      :num => 100,
    })

    def initialize
      super

      setn(:conc, '-c', '--concurrency c',
           'specify concurrent level [default: 10]')
      setn(:num,  '-n', '--number n',
           'specify request number per thread [default: 100]')
    end
  end
end
