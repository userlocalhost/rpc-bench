require 'protobuf/message'
require 'protobuf/rpc/service'

require 'grpc'
require 'thread'

module RPCBench
  class GRPC < Driver
    SERVICE_NAME = 'rpc_bench'

    def initialize opts
      @opts = opts
    end

    def send_request data, count
      stub = Calc::Stub.new("#{@opts[:host]}:#{@opts[:port]}", :this_channel_is_insecure)

      (1..count).each do |_|
        p stub.calc_tmp(TmpRequest.new(num: data)).num
      end
    end

    ##
    # Message Classes
    #
    class TmpRequest < Protobuf::Message; end
    class TmpReply < Protobuf::Message; end

    ##
    # Message Fields
    #
    class TmpRequest
      required :int32, :num, 1
    end
    class TmpReply
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
  end
end
