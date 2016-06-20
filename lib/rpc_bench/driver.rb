module RPCBench
  class Driver
    def set_handler handler
      @handler = handler
    end

    def send(data, count)
      begin
        send_request(data, count)
      rescue NameError => e
        puts "[warning] failed to send request (#{e})"
      end
    end

    def close
      # nop
    end
  end
end
