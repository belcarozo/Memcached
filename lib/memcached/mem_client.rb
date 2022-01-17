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
            while command = $stdin.gets
                @socket.puts command
                command_words = command.split
                command = command_words[0]
                case command

                when 'gets', 'get'
                    loop do
                        line = @socket.gets
                        $stdout.puts line
                        if line.chomp == FIN
                            break
                        end
                        size = line.split[3].to_i
                        value = @socket.read(size + 1)
                        $stdout.puts value
                    end
                when 'set', 'append', 'prepend', 'add', 'cas' 
                    value = $stdin.gets
                    @socket.puts value
                    $stdout.puts @socket.gets
                else 
                    $stdout.puts @socket.gets
                end
            end
            @socket.close
        end
    end
host = ARGV[0]
port = ARGV[1]

client = Client.new(host, port)
client.run
end
