#!/usr/bin/env bats

load test_helper

@test 'foo' {
   assert_unequal "1" "1" "should be unequal"
}

@test 'bar' {
   assert_unequal "1" "1" 
}

@test 'baz' {
   assert_unequal "1" "1" ""
}

@test 'bletch' {
  output="1\2"
  IFS=$'\n' lines=($output)
  assert_line 1 "3" "mismatch"
}