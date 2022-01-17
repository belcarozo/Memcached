require_relative 'constants'
require_relative 'info'

module Memcached
    class MemHash

        def initialize()
            @storage = Hash.new
        end

        def delete_if_expired(key)
            has_key = @storage.has_key?(key)
            if has_key && @storage[key].expired?
                @storage.delete(key)
            end
        end


        def get(key)
            delete_if_expired(key);
            return @storage[key]
        end

        def get_many(keys)
            return_info = []
            i = 1
            while keys[i]
                if get(keys[i])
                    return_info << get(keys[i])
                end
                i = i + 1
            end
            return return_info
        end

        def set(value, key, flags, exptime, size, cas_key)
            info = Info.new(value.chomp, flags, exptime, size, cas_key)
            @storage[key] = info
        end

        def add(value, key, flags, exptime, size, cas_key)
            delete_if_expired(key)
            has_key = @storage.has_key?(key)
            if !has_key
                info = Info.new(value.chomp, flags, exptime, size, cas_key)
                @storage[key] = info
                return true
            else 
                return false
            end
        end

        def replace(value, key, flags, exptime, size, cas_key)
            delete_if_expired(key)
            has_key = @storage.has_key?(key)
            if has_key
                info = Info.new(value.chomp, flags, exptime, size, cas_key) #eficiencia?
                @storage[key] = info
                return true
            else
                return false
            end
        end

        def append(value, key, flags, exptime, size, cas_key)
            delete_if_expired(key)
            has_key = @storage.has_key?(key)
            if has_key
                @storage[key].value = @storage[key].value + value.chomp
                @storage[key].size = @storage[key].size.to_i + size.to_i
                @storage[key].cas_key = cas_key
                return true
            else 
                return false
            end
        end   

        def prepend(value, key, flags, exptime, size, cas_key)
            delete_if_expired(key)
            has_key = @storage.has_key?(key)
            if has_key
                @storage[key].value = value.chomp + @storage[key].value
                @storage[key].size = @storage[key].size.to_i + size.to_i
                @storage[key].cas_key = cas_key
                return true
            else 
                return false
            end
        end

        def cas(value, key, flags, exptime, size, cas_key, new_cas_key)
            delete_if_expired(key)
            has_key = @storage.has_key?(key)
            if has_key
                if cas_key.to_i == @storage[key].cas_key
                    info = Info.new(value.chomp, flags, exptime, size, new_cas_key)
                    @storage[key] = info
                    return CAS_STORED
                else 
                    return CAS_EXISTS
                end
            else
                return CAS_NOT_FOUND
            end
        end

        def delete(key)
            has_key = @storage.has_key?(key)
            if has_key
                @storage.delete(key)
            end
        end
    end
end

