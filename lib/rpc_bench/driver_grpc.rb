require 'protobuf/message'
require 'protobuf/rpc/service'

require 'grpc'
require 'thread'

module RPCBench
  module GRPC
    SERVICE_NAME = 'rpc_bench'

    ##
    # Message Fields
    #
    class TmpRequest < Protobuf::Message
      required :int32, :num, 1
    end
    class TmpReply < Protobuf::Message
      required :int32, :num, 1
    end

    ##
    # Service Classes
    #
    class ServiceCalc < Protobuf::Rpc::Service
      rpc :calc_tmp, TmpRequest, TmpReply
    end

    class Calc
      class Service
        include ::GRPC::GenericService

        self.marshal_class_method = :encode
        self.unmarshal_class_method = :decode
        self.service_name = SERVICE_NAME

        rpc :CalcTmp, TmpRequest, TmpReply
      end
      Stub = Service.rpc_stub_class
    end

    class Client < Driver
      def initialize opts
        @opts = opts
      end

      def sendmsg stub, data
        begin
          p stub.calc_tmp(RPCBench::GRPC::TmpRequest.new(num: data)).num
        rescue ::GRPC::BadStatus => e
          if(e.code == 8)
            sendmsg stub, data
          else
            puts "[warning] other error is occurrs"
          end
        end
      end

      def send_request(data, count)
        stub = RPCBench::GRPC::Calc::Stub.new("#{@opts[:host]}:#{@opts[:port]}", :this_channel_is_insecure)

        (1..count).each do |_|
          sendmsg stub, data
        end
      end
    end
    class Server < Driver
      def initialize opts
        @opts = opts
      end

      def run
        s = ::GRPC::RpcServer.new
        s.add_http2_port("#{@opts[:host]}:#{@opts[:port]}", :this_port_is_insecure)
        s.handle(MyCalc)
        s.run_till_terminated
      end

      class MyCalc < RPCBench::GRPC::Calc::Service
        def calc_tmp(value, _unused_call)
          TmpReply.new(num: @handler.callback(value.num))
        end
      end
    end
  end
end
