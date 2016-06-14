module RPCBench
  class Driver
    def set_handler handler
      @handler = handler
    end

    def send(data)
      begin
        send_request(data)
      rescue NameError => e
        puts "[warning] failed to send request (#{e})"
      end
    end

    def close
      # nop
    end
  end
end
