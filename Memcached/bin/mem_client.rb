#!/usr/bin/env ruby
#$: File.join(File.dirname(__FILE__), '..', 'lib')

require 'socket'
require '../lib/memcached'
# require_relative 'mem_hash' #'../lib/memcached/mem_hash'
# require_relative 'constants' #'../lib/memcached/constants'
# require_relative 'mem_server'

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
                command = command_words[COMMAND]
                
                case command
                when 'quit'
                    @socket.close
                    break
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
                when 'set', 'append', 'prepend', 'add'
                    noreply = command_words[NOREPLY]
                    value = $stdin.gets
                    @socket.puts value
                    $stdout.puts @socket.gets unless noreply
                when 'cas'
                    noreply = command_words[CAS_NOREPLY]
                    value = $stdin.gets
                    @socket.puts value
                    $stdout.puts @socket.gets unless noreply
                else 
                    $stdout.puts @socket.gets
                end
            end

        end
    end
host = ARGV[0]
port = ARGV[1]

client = Client.new(host, port)
client.run
end
