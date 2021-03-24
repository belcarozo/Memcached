require 'socket'
require_relative 'mem_hash'
#require_relative 'mem_client'

module Memcached
    class Server

        def initialize(hostname, port)
            @hostname = hostname
            @port = port
            @mem = MemHash.new()
        end

        def run #tiene que arrancar a correr cuando arranco en programa. puedo hacer un main?
            #Puedo hacer un main. se hace abajo. sabelo

            puts 'server running...' #TODO mejor mensaje

            server = TCPServer.new(@hostname, @port)

            loop do
                Thread.start(server.accept) do |client|
                    command = nil

                    while command != 'quit' 
                        full_command = client.gets.chomp
                        command_words = full_command.split  #(/\W+/)
                        
                        command = command_words[0]
                        key = command_words[1]
                        flags = command_words[2]
                        exptime = command_words[3]
                        size = command_words[4]

                        case command
                        when 'get'
                            if @mem.get(key)
                                puts 'VALUE' + @mem.get(key).to_string
                            else 
                                puts 'END'
                        when 'gets'
                            #TODO
                        when 'set'
                            @mem.set(key, flags, exptime, size)
                        when 'add'
                            @mem.add(key, flags, exptime, size)
                        when 'append'
                            @mem.append(key, flags, exptime, size)
                        when 'prepend'
                            @mem.prepend(key, flags, exptime, size)
                        when 'cas'
                            #TODO entender que es esto
                        else
                            #TODO error 
                        end
                    end
                end
            end
        end
    end
host = ARGV[0]
port = ARGV[1]

server = Server.new(host, port)
server.run
end

