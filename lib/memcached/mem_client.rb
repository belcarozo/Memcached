require 'socket'
require_relative 'mem_hash'
require_relative 'mem_server'

module Memcached
    class Client

        def initialize(hostname, port)
            @hostname = hostname
            @port = port
            @socket = TCPSocket.open(@hostname, @port)
        end

        def run
            loop do
                command = gets.chomp
                @socket.puts command
                puts socket.readpartial(MAX_LEN)
            end
        end
    end
host = ARGV[0]
port = ARGV[1]

client = Client.new(host, port)
client.run
end
