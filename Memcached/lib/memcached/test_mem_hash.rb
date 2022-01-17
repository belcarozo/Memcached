require_relative "mem_hash"
require "test/unit"
include Test::Unit::Assertions


module Memcached
    class MemHashTest
        def initialize(key, value, flags, expseconds)
            @mem = MemHash.new
            @sample_key = key
            @sample_value = value
            @sample_flags = flags
            @sample_size = @sample_value.bytesize
            @never_expires = 0
            @immediately_expired = -1
            @expseconds = expseconds
         end

        def test_get_nonexistent_key
            test_info = @mem.get(@sample_key)
            assert_nil(test_info, "Unexpected data found - should have been nil")
        end

        def test_set_new_key
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            test_info = @mem.get(@sample_key)
            assert_not_nil(test_info, "The data was not stored")
            assert_equal(@sample_value, test_info.value, "Expected and stored value does not match")
            assert_equal(@sample_flags, test_info.flags, "Expected and stored flags do not match")
            assert_equal(@sample_size, test_info.size, "Expected and stored size does not match")
            @mem.delete(@sample_key)
        end

        def test_set_existing_key
            @mem.set('oldvalue', @sample_key, @sample_flags.to_i + 1, @never_expires, 8, 0)
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            test_info = @mem.get(@sample_key)
            assert_not_nil(test_info, "The data was not stored")
            assert_equal(@sample_value, test_info.value, "Should have updated value")
            assert_equal(@sample_flags, test_info.flags, "Should have updated flags")
            assert_equal(@sample_size, test_info.size, "Should have updated size")
            @mem.delete(@sample_key)
        end

        def test_get_non_expired
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            test_info = @mem.get(@sample_key)
            assert_equal(@sample_value, test_info.value, "Expected and given value does not match")
            assert_equal(@sample_flags, test_info.flags, "Expected and given flags do not match")
            assert_equal(@sample_size, test_info.size, "Expected and given size does not match")
            @mem.delete(@sample_key)
        end

        def test_get_non_expired_then_expired
            @mem.set(@sample_value, @sample_key, @sample_flags, @expseconds, @sample_size, 0)
            test_info = @mem.get(@sample_key)
            assert_equal(@sample_value, test_info.value, "Expected and given value does not match")
            assert_equal(@sample_flags, test_info.flags, "Expected and given flags do not match")
            assert_equal(@sample_size, test_info.size, "Expected and given size does not match")
            puts "Waiting #@expseconds seconds until expiration"
            sleep @expseconds
            test_info = @mem.get(@sample_key)
            assert_nil(test_info, "Expired data was not purged correctly")
        end

        def test_get_immediately_expired
            @mem.set(@sample_value, @sample_key, @sample_flags, @immediately_expired, @sample_size, 0)
            test_info = @mem.get(@sample_key)
            assert_nil(test_info, "Expired data was not purged correctly")
        end

        def test_get_two_existing_keys
            second_key = @sample_key + "2"
            second_value = @sample_value + "2"
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            @mem.set(second_value, second_key, @sample_flags, @never_expires, @sample_size.to_i + 1, 1)
            keys = nil, @sample_key, @sample_key + "2"
            test_info = @mem.get_many(keys)
            assert_equal(@sample_value, test_info[0].value, "Expected and given value does not match - 1st key")
            assert_equal(@sample_flags, test_info[0].flags, "Expected and given flags do not match - 1st key")
            assert_equal(@sample_size, test_info[0].size, "Expected and given size does not match - 1st key")
            assert_equal(second_value, test_info[1].value, "Expected and given value does not match - 2nd key")
            assert_equal(@sample_flags, test_info[1].flags, "Expected and given flags do not match - 2nd key")
            assert_equal(@sample_size.to_i + 1, test_info[1].size, "Expected and given size does not match - 2nd key")
            @mem.delete(@sample_key)
            @mem.delete(second_key)
        end

        def test_get_some_keys_exist_some_does_not
            second_key = @sample_key + "2"
            second_value = @sample_value + "2"
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            @mem.set(second_value, second_key, @sample_flags, @never_expires, @sample_size.to_i + 1, 1)
            keys = nil, @sample_key, 'not_a_key', 'also_not_a_key', @sample_key + "2"
            test_info = @mem.get_many(keys)
            assert_equal(@sample_value, test_info[0].value, "Expected and given value does not match - 1st key")
            assert_equal(@sample_flags, test_info[0].flags, "Expected and given flags do not match - 1st key")
            assert_equal(@sample_size, test_info[0].size, "Expected and given size does not match - 1st key")
            assert_equal(second_value, test_info[1].value, "Expected and given value does not match - 2nd key")
            assert_equal(@sample_flags, test_info[1].flags, "Expected and given flags do not match - 2nd key")
            assert_equal(@sample_size.to_i + 1, test_info[1].size, "Expected and given size does not match - 2nd key")
            @mem.delete(@sample_key)
            @mem.delete(second_key)
        end


        def test_gets_non_expired
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            test_info = @mem.get(@sample_key)
            assert_equal(0, test_info.cas_key, "Expected and given cas_key does not match")
            @mem.delete(@sample_key)
        end

        def test_add_new_key
            @mem.add(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            test_info = @mem.get(@sample_key)
            assert_not_nil(test_info, "The data was not stored")
            assert_equal(@sample_value, test_info.value, "Expected and stored value does not match")
            assert_equal(@sample_flags, test_info.flags, "Expected and stored flags do not match")
            assert_equal(@sample_size, test_info.size, "Expected and stored size does not match")
            @mem.delete(@sample_key)
        end
        
        def test_add_existing_key
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            new_value = 'new value!'
            added = @mem.add(new_value, @sample_key, @sample_flags, @never_expires, new_value.bytesize, 0)
            test_info = @mem.get(@sample_key)
            assert(!added, "The new value was not supposed to be added")
            assert_equal(@sample_value, test_info.value, "Expected and stored value does not match")
            @mem.delete(@sample_key)
        end

        def test_replace_new_key
            replaced = @mem.replace(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            assert(!replaced, "There was nothing to replace")
        end

        def test_replace_existing_key
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            new_value = 'new value!'
            replaced = @mem.replace(new_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            test_info = @mem.get(@sample_key)
            assert(replaced, "The item should have been replaced")
            assert_equal(new_value, test_info.value, "Expected and stored value does not match")
            @mem.delete(@sample_key)
        end

        def test_append_nonexistent_key
            appended = @mem.append(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            assert(!appended, "There was nothing to append to")
        end

        def test_append_existing_key
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            new_value = 'new value!'
            new_flags = @sample_flags.to_i + 1
            new_size = new_value.bytesize
            appended = @mem.append(new_value, @sample_key, new_flags, @immediately_expired, new_size, 0)
            test_info = @mem.get(@sample_key)
            assert_not_nil(test_info, "Should not modify exptime")
            assert(appended, "Should have been appended")
            assert_equal(@sample_value + new_value, test_info.value, "Expected and stored value does not match")
            assert_equal(@sample_flags, test_info.flags, "Should not modify flags")
            assert_equal(@sample_size.to_i + new_size, test_info.size, "Should have added sizes")
            @mem.delete(@sample_key)
        end

        def test_prepend_nonexistent_key
            prepended = @mem.append(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            assert(!prepended, "There was nothing to prepend to")
        end

        def test_prepend_existing_key
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            new_value = 'new value!'
            new_flags = @sample_flags.to_i + 1
            new_size = new_value.bytesize
            prepended = @mem.prepend(new_value, @sample_key, new_flags, @immediately_expired, new_size, 0)
            test_info = @mem.get(@sample_key)
            assert_not_nil(test_info, "Should not modify exptime")
            assert(prepended, "Should have been appended")
            assert_equal(new_value + @sample_value, test_info.value, "Expected and stored value does not match")
            assert_equal(@sample_flags, test_info.flags, "Should not modify flags")
            assert_equal(@sample_size.to_i + new_size, test_info.size, "Should have added sizes")
            @mem.delete(@sample_key)
        end

        def test_cas_caskey_matches_key
            @mem.set(@sample_value, @sample_key, @sample_flags.to_i + 1, @never_expires, @sample_size, 0)
            new_value = 'new value!'
            cas_key = @mem.get(@sample_key).cas_key
            response = @mem.cas(new_value, @sample_key, @sample_flags, @never_expires, new_value.bytesize, cas_key, 1)
            test_info = @mem.get(@sample_key)
            assert_equal(response, CAS_STORED, "Should have indicated the value was stored")
            assert_equal(new_value, test_info.value, "Should have updated value")
            assert_equal(@sample_flags, test_info.flags, "Should have updated flags")
            assert_equal(new_value.bytesize, test_info.size, "Should have updated size")
            @mem.delete(@sample_key)
        end

        def test_cas_caskey_does_not_match_key_but_exists
            @mem.set(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0)
            new_value = 'new value!'
            response = @mem.cas(new_value, @sample_key, @sample_flags.to_i + 1, @never_expires, new_value.bytesize, 1, 2)
            test_info = @mem.get(@sample_key)
            assert_equal(response, CAS_EXISTS, "Should have indicated it existed")
            assert_equal(@sample_value, test_info.value, "Expected and stored value does not match")
            assert_equal(@sample_flags, test_info.flags, "Expected and stored flags do not match")
            assert_equal(@sample_size, test_info.size, "Expected and stored size does not match")
            @mem.delete(@sample_key)
        end

        def test_cas_nonexistent_key
            response = @mem.cas(@sample_value, @sample_key, @sample_flags, @never_expires, @sample_size, 0, 1)
            test_info = @mem.get(@sample_value)
            assert_equal(response, CAS_NOT_FOUND, "Should have indicated the key does not exist")
            assert_nil(test_info, "Nothing should be stored")
            @mem.delete(@sample_key)
        end
    end
end