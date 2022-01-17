module Memcached
    class Info

        def initialize(value, flags, exptime, size, cas_key) 

            @flags = flags

            if 0 < exptime && exptime <= MAX_EXPTIME_OFFSET
                time_now = Time.now
                @exptime = time_now + exptime.to_i
                @exptime = @exptime.to_i
            else 
                @exptime = exptime.to_i
            end

            @size = size

            @value = value

            @cas_key = cas_key.to_i

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

        def cas_key
            @cas_key
        end

        #setters
        def value=(value)
            @value = value
        end

        def size=(size)
            @size = size
        end

        def exptime=(exptime)
            @size = size
        end

        def flags=(flags)
            @flags = flags 
        end
        
        def cas_key=(cas_key)
            @cas_key = cas_key
        end

        #methods
        def flags_and_size
            return " #@flags #@size"
        end

        def flags_size_and_cas
            return " #@flags #@size #@cas_key"
        end

        def expired?
            current_time = Time.now
            #puts current_time.to_i
            if @exptime <= current_time.to_i  && @exptime != 0
                return true
            else 
                return false
            end
        end

    end
end