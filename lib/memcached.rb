# frozen_string_literal: true
#vendría a ser como el main, y en la carpeta memcache van todos los archivitos
require_relative "memcache/version"
require_relative "mem_commands"
require_relative "mem_server"
require_relative "mem_client"

module Memcache
  class Error < StandardError #tengo que ver si esto se puede borrar
  end
end
