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
            @server = TCPServer.new(@hostname, @port)
            @cas_key = 0
        end

        def run

            puts 'Server running...' 
            puts "Connected to #@hostname, port #@port" 

            #server = TCPServer.new(@hostname, @port)
            
            while(client = @server.accept)
                Thread.start do
                    #loop do
                    while    full_command = client.gets()
                        command_words = full_command.split
                        puts command_words
                        puts 'ajaso'
                        self.switch(command_words, client)
                    end
                end
            end
        end

        def switch(command_words, client) #TODO noreply

            command = command_words[0]

            case command

            # when 'get'
            #     key = command_words[1]
            #     key_info = @mem.get(key)
            #     if key_info
            #         client.puts 'VALUE ' + key + key_info.flags_and_size
            #         client.puts key_info.value
            #     end 
            #     client.puts(FIN)
            
            when 'get'
                i = 1
                while command_words[i]
                    key = command_words[i]
                    key_info = @mem.get(key)
                    if key_info
                        client.puts 'VALUE ' + key + key_info.flags + key_info.size
                        client.puts key_info.value
                    end
                    i = i + 1
                end
                    client.puts(FIN)

            when 'gets'
                i = 1
                while command_words[i]
                    key = command_words[i]
                    key_info = @mem.get(key)
                    if key_info
                        client.puts 'VALUE ' + key + key_info.flags + key_info.size + key_info.cas_key
                        client.puts key_info.value
                    end
                    i = i + 1
                end
                    client.puts(FIN)
            when 'quit'
                client.puts(QUIT)
                client.close #TODO no funciona
            else 
                command, key, flags, exptime, size, noreply = command_words
                if size
                    f_int = Integer(flags) rescue false
                    exp_int = Integer(exptime) rescue false
                    if f_int && exp_int
                        case command
                        when 'set'
                            while value = client.gets()
                                if value.bytesize == size.to_i + 1
                                    @mem.set(value, key, flags, exptime.to_i, size, @cas_key)
                                    client.puts(STORED) unless noreply
                                    break
                                else
                                    client.puts(CLIENT_ERROR_CHUNK) unless noreply
                                    break
                                end
                            end
                            
            
                        when 'add'            
                            while value = client.gets()
                                if value.bytesize == size.to_i + 1
                                    if @mem.add(value, key, flags, exptime.to_i, size, @cas_key)
                                        client.puts(STORED) unless noreply
                                        break
                                    else 
                                        client.puts(NOT_STORED) unless noreply
                                        break
                                    end
                                else 
                                    client.puts(CLIENT_ERROR_CHUNK) unless noreply
                                    break
                                end
                            end 
            
                        when 'replace'
                            while value = client.gets()
                                if value.bytesize == size.to_i + 1
                                    if @mem.replace(value, key, flags, exptime.to_i, size, @cas_key)
                                        client.puts(STORED) unless noreply
                                        break
                                    else 
                                        client.puts(NOT_STORED) unless noreply
                                        break
                                    end
                                else
                                    client.puts(CLIENT_ERROR_CHUNK) unless noreply
                                    break
                                end
                            end
            
                        when 'append'
                            while value = client.gets()
                                if value.bytesize == size.to_i + 1
                                    if @mem.append(value, key, flags, exptime.to_i, size, @cas_key)
                                        client.puts(STORED) unless noreply
                                        break
                                    else
                                        client.puts(NOT_STORED) unless noreply
                                        break
                                    end
                                else
                                    client.puts(CLIENT_ERROR_CHUNK) unless noreply
                                    break
                                end
                            end
            
                        when 'prepend'
                            while value = client.gets()
                                if value.bytesize == size.to_i + 1
                                    if @mem.prepend(value, key, flags, exptime.to_i, size, @cas_key)
                                        client.puts(STORED) unless noreply
                                        break
                                    else
                                        client.puts(NOT_STORED) unless noreply
                                        break
                                    end
                                else
                                    puts value.bytesize 
                                    puts size.to_i + 1
                                    client.puts(CLIENT_ERROR_CHUNK) unless noreply
                                    break
                                end
                            end
            
                        when 'cas'
                            #TODO entender que es esto
                        else
                            client.puts(ERROR)
                        end
                    else 
                        client.puts(CLIENT_ERROR_COMMAND) #bad flags or time
                    end
                else 
                    client.puts(ERROR) #bad sizes
                end
                puts 'aaa'
            end #case
        end #switch
    end #class
host = ARGV[0]
port = ARGV[1]

server = Server.new(host, port)
server.run
end


