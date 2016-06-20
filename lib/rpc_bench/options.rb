require "optparse"

module RPCBench
  class Options
    MODE_VALUES = ['rabbitmq', 'stomp', 'zeromq', 'grpc']

    OPT_DEFAULT = {
      :host => 'localhost',
      :port => 5672,
      :mode => 'rabbitmq',
      :conc => 10,
      :num => 100,
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
      
      sets(:host, '-s', '--server s',
           'specify server to send request')
      setn(:port, '-p', '--port s',
           'specify port number on which server listens')
      sets(:mode, '-m', '--mode m',
           'specify benchmark mode {rabbitmq|rabbitmq-stomp|newtmq|zeromq|grpc} [default: rabbitmq]')
      setn(:conc, '-c', '--concurrency c',
           'specify concurrent level [default: 10]')
      setn(:num,  '-n', '--number n',
           'specify request number per thread [default: 100]')
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
end
