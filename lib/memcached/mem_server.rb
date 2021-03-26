require 'socket'
require_relative 'mem_hash'
require_relative 'constants'
require_relative 'mem_client'

module Memcached
    class Server

        def initialize(hostname, port)
            @hostname = hostname
            @port = port
            @mem = MemHash.new()
        end

        def run #tiene que arrancar a correr cuando arranco en programa. puedo hacer un main?
            #Puedo hacer un main. se hace abajo. sabelo

            puts 'Server running...' 
            puts "Connected to #@hostname, port #@port" 

            server = TCPServer.new(@hostname, @port)

            loop do
                Thread.start(server.accept) do |client|
                    #command = 1
                    full_command = client.gets()
                    puts full_command
                    while full_command = client.gets()
                        #while full_command = client.gets
                        puts full_command
                        command_words = full_command.split  #(/\W+/)
                        
                        command = command_words[0]
                        key = command_words[1]
                        flags = command_words[2]
                        exptime = command_words[3]
                        size = command_words[4]

                        case command

                        when 'get'
                            value = @mem.get(key)
                            if value
                                client.write('VALUE' + value.to_string)
                            else 
                                client.write(CANNOT_GET)
                            end

                        when 'gets'
                            #TODO
            
                        when 'set'
                            value = client.gets.chomp
                            if value.bytesize = size
                                @mem.set(value, key, flags, exptime, size)
                            else
                                client.write(CLIENT_ERROR)
                            end

                        when 'add'            
                            value = client.gets.chomp
                            if value.bytesize = size
                                if @mem.add(value, key, flags, exptime, size)
                                    client.write(STORED)
                                else 
                                    client.write(NOT_STORED)
                                end
                            else 
                                client.write(CLIENT_ERROR)
                            end

                        when 'replace'
                            value = client.gets.chomp
                            if value.bytesize = size
                                if @mem.replace(value, key, flags, exptime, size)
                                    client.write(STORED)
                                else 
                                    client.write(NOT_STORED)
                                end
                            else
                                client.write(CLIENT_ERROR)
                            end

                        when 'append'
                            value = client.gets.chomp
                            if value.bytesize = size
                                if @mem.append(value, key, flags, exptime, size)
                                    client.write STORED
                                else
                                    client.write(NOT_STORED)
                                end
                            else
                                client.write(CLIENT_ERROR)
                            end

                        when 'prepend'
                            value = client.gets.chomp
                            if value.bytesize = size
                                if @mem.prepend(value, key, flags, exptime, size)
                                    client.write(STORED)
                                else
                                    client.write(NOT_STORED)
                                end
                            else
                                client.write(CLIENT_ERROR)
                            end

                        when 'cas'
                            #TODO entender que es esto
                        when 'quit'
                            break
                        else
                            client.write(ERROR)
                        end
                    end
                
                    client.write(QUIT)
                end
            end
        end
    end
host = ARGV[0]
port = ARGV[1]

server = Server.new(host, port)
server.run
end

