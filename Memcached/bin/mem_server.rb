#!/usr/bin/env ruby
require 'socket'
require '../lib/memcached.rb'

module Memcached
    class Server

        def initialize(hostname, port) #TODO CAMBIAR ESTO
            @hostname = hostname
            @port = port
            @mem = MemHash.new()
            @server = TCPServer.new(@hostname, @port)
            @cas_key = 0
        end

        def run

            
            puts 'Server running...' 
            puts "Connected to #@hostname, port #@port" 

            #server = TCPServer.new(@hostname, @port)
            
            while(client = @server.accept)
                Thread.start do
                    command = nil
                    #loop do
                    while full_command = client.gets()
                        command_words = full_command.split
                        self.switch(command_words, client)
                        if command_words[COMMAND].chomp == 'quit'
                            break
                        end
                    end
                end
            end
        end

        def switch(command_words, client) #TODO noreply

            command = command_words[COMMAND]

            case command

            when 'get'
                info_of_keys = @mem.get_many(command_words)
                i = 0
                while info_of_keys[i]
                    key = command_words[i + 1]
                    client.puts 'VALUE ' + key + info_of_keys[i].flags_and_size
                    client.puts info_of_keys[i].value
                    i = i + 1
                end
                    client.puts(FIN)

            when 'gets'
                info_of_keys = @mem.get_many(command_words)
                i = 0
                while info_of_keys[i]
                    key = command_words[i + 1]
                    client.puts 'VALUE ' + key + info_of_keys[i].flags_size_and_cas
                    client.puts info_of_keys[i].value
                    i = i + 1
                end
                    client.puts(FIN)

            when 'quit'
                client.puts(QUIT)
                client.close #TODO ERROR
            else 
                command, key, flags, exptime, size = command_words
                if size
                    f_int = Integer(flags) rescue false
                    exp_int = Integer(exptime) rescue false
                    if f_int && exp_int
                        
                        case command

                        when 'set'
                            noreply = command_words[NOREPLY]
                            value = client.gets()
                            if value.bytesize == size.to_i + 1
                                if @mem.set(value, key, flags, exptime.to_i, size, @cas_key)
                                    @cas_key = @cas_key + 1
                                    client.puts(STORED) unless noreply
                                else
                                    client.puts(NOT_STORED) unless noreply
                                end
                            else
                                client.puts(CLIENT_ERROR_CHUNK) unless noreply
                            end

                        when 'add'       
                            noreply = command_words[NOREPLY]     
                            value = client.gets()
                            if value.bytesize == size.to_i + 1
                                if @mem.add(value, key, flags, exptime.to_i, size, @cas_key)
                                    @cas_key = @cas_key + 1
                                    client.puts(STORED) unless noreply
                                else 
                                    client.puts(NOT_STORED) unless noreply
                                end
                            else 
                                client.puts(CLIENT_ERROR_CHUNK) unless noreply
                            end
                        
            
                        when 'replace'
                            noreply = command_words[NOREPLY]
                            value = client.gets()
                            if value.bytesize == size.to_i + 1
                                if @mem.replace(value, key, flags, exptime.to_i, size, @cas_key)
                                    @cas_key = @cas_key + 1
                                    client.puts(STORED) unless noreply
                                else 
                                    client.puts(NOT_STORED) unless noreply
                                end
                            else
                                client.puts(CLIENT_ERROR_CHUNK) unless noreply
                            end
            
                        when 'append'
                            noreply = command_words[NOREPLY]
                            value = client.gets()
                            if value.bytesize == size.to_i + 1
                                if @mem.append(value, key, flags, exptime.to_i, size, @cas_key)
                                    @cas_key = @cas_key + 1
                                    client.puts(STORED) unless noreply
                                else
                                    client.puts(NOT_STORED) unless noreply
                                end
                            else
                                client.puts(CLIENT_ERROR_CHUNK) unless noreply
                            end
                        
            
                        when 'prepend'
                            noreply = command_words[NOREPLY]
                            value = client.gets()
                            if value.bytesize == size.to_i + 1
                                if @mem.prepend(value, key, flags, exptime.to_i, size, @cas_key)
                                    @cas_key = @cas_key + 1
                                    client.puts(STORED) unless noreply
                                else
                                    client.puts(NOT_STORED) unless noreply
                                end
                            else
                                puts value.bytesize 
                                puts size.to_i + 1
                                client.puts(CLIENT_ERROR_CHUNK) unless noreply
                            end
                        
            
                        when 'cas'
                            cas_key = command_words[CAS_KEY] #TODO arrays constanaes
                            noreply = command_words[NOREPLY]
                            value = client.gets()
                            if value.bytesize == size.to_i + 1
                                result = @mem.cas(value, key, flags, exptime.to_i, size, cas_key, @cas_key)
                                if result == CAS_STORED
                                    @cas_key = @cas_key + 1
                                    client.puts(STORED) unless noreply
                                elsif result == CAS_EXISTS
                                    client.puts(EXISTS) unless noreply
                                else 
                                    client.puts(NOT_FOUND) unless noreply
                                end
                            else
                                client.puts(CLIENT_ERROR_CHUNK) unless noreply #TODO error abajo de eso
                            end
                        

                        else
                            client.puts(ERROR)
                        end
                    else 
                        client.puts(CLIENT_ERROR_COMMAND) #bad flags or time
                    end
                else 
                    client.puts(ERROR) #bad sizes
                end
              
            end #case
        end #switch
    end #class
host = ARGV[0]
port = ARGV[1]

server = Server.new(host, port)
server.run
end


