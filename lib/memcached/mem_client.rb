require 'socket'
require_relative 'mem_commands'
#require_relative 'mem_server'

puts "Please enter hostname"
hostname = gets.chomp

puts "Please enter port"
port = gets.chomp

socket = TCPSocket.open(hostname, port)
#hago lo que tengo que hacer
#socket.close no se si va xq dice que no se tiene que desconectar el cliente
