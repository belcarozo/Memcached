
require_relative "test_mem_hash"

module Memcached
    test = MemHashTest.new('value', 'key', 19, 2)
    #test_set
    test.test_set_new_key
    test.test_set_existing_key
    #test_get
    test.test_get_nonexistent_key
    test.test_get_non_expired
    test.test_get_non_expired_then_expired
    test.test_get_two_existing_keys
    test.test_get_some_keys_exist_some_does_not
    test.test_gets_non_expired
    #test_add
    test.test_add_new_key
    test.test_add_existing_key
    #test_replace
    test.test_replace_new_key
    test.test_replace_existing_key
    #test_append
    test.test_append_existing_key
    test.test_append_nonexistent_key
    #test_prepend
    test.test_prepend_existing_key
    test.test_prepend_nonexistent_key
    #test_cas
    test.test_cas_caskey_matches_key
    test.test_cas_caskey_does_not_match_key_but_exists
    test.test_cas_nonexistent_key
    puts 'TESTS WERE SUCCESSFUL'
end