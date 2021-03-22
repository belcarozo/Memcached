require 'socket'
require_relative 'mem_commands'
#require_relative 'mem_client'

puts "Please enter the desired TCP port for the server to listen" #hacerlo todo en uno
port = gets.chomp

server = TCPServer.open(port)
loop {
    Thread.start(server.accept) do |client|
    #hago lo que tengo que hacer con client.puts o lo que sea
}