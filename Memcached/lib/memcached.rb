# frozen_string_literal: true
#vendría a ser como el main, y en la carpeta memcache van todos los archivitos
require_relative "./memcached/version.rb"
require_relative "./memcached/constants"
require_relative "./memcached/info"
require_relative "./memcached/mem_hash"
require "../bin/mem_server"
require "../bin/mem_client"

module Memcached
  class Error < StandardError #tengo que ver si esto se puede borrar
  end
end
