require 'socket'
require_relative 'mem_hash'
#require_relative 'mem_server'

module Memcached
    class Client

        def initialize(hostname, port)
            @hostname = hostname
            @port = port
        end

        def run
            socket = TCPSocket.open(hostname, port)
    end
end