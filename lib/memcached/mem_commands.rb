require_relative 'constants'

#TODO: ver que hacen las flags y como usar eso y si lo tengo que guardar

module Memcached
    class Info

        def initialize(flags, exptime, size, value) #le tengo que poner la key?
            @flags = flags
            @exptime = exptime
            @size = size
            @value = value
        end

        #getters
        def flags
            @flags
        end

        def exptime
            @exptime
        end

        def size
            @size
        end

        def value
            @value
        end

        #setters
        def value=(value)
            @value = value
        end
        
    end

    class MemCommands

        @@storage = Hash.new #TODO: fijarme que tipo de hash usa memcached

        def get(key)
            if !@@storage.[key]
                puts 'The key was never stored or has expired'
            else return @@storage.[key]
            end
        end

        def gets(key) #? keys?

        end

        def set(key, flags, exptime, size)
            value = gets.chomp
            @@storage.[key] = value #o hash.store(key, value) + exp y eso
        end

        def add(key, flags, exptime, size)
            has_key = @@storage.has_key?(key)
            if !has_key
                value = gets.chomp
                #new item
                @@storage.[key] = value
            else puts 'The key already exists'
            
        end

        def replace(key, flags, exptime, size)
            has_key = @@storage.has_key?(key)
            if has_key 
                value = gets.chomp
                @@storage.[key] = value
            else puts 'The key was never stored or has expired'
            end
        end

        def append(key, flags, exptime, size)
        
        end

        def prepend(key, flags, exptime, size)

        end

        def cas(key, flags, exptime, size, unique_cas_key)

        end

    end
end
