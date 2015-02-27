create or replace package xtras_generators as

-- The MIT License (MIT)
-- 
-- Copyright (c) 2015 Diego Martinelli
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-- Generate random numbers
function generate_random_numbers(
    p_size in number,
    p_min in number := 0,
    p_max in number := 1) return xtras_numbers_t pipelined;

-- Generate random strings
function generate_random_strings(
    p_size in number,
    p_option in char,
    p_string_len in number) return xtras_strings_t pipelined;

-- Generate series of number
function generate_series(
    p_start in pls_integer,
    p_stop in pls_integer,
    p_step in pls_integer := 1) return xtras_numbers_t pipelined;

-- Generate series of timestamps
function generate_series(
    p_start in timestamp,
    p_stop in timestamp,
    p_step in dsinterval_unconstrained := interval '1' day) return xtras_timestamps_t pipelined;

-- Generate series of timestamps
function generate_series(
    p_start in timestamp,
    p_stop in timestamp,
    p_step in yminterval_unconstrained := interval '1' month) return xtras_timestamps_t pipelined;

-- Generate fibonacci numbers in a range
function generate_fibonacci(
    p_min in number,
    p_max in number) return xtras_numbers_t pipelined;

-- Generate the first N fibonacci numbers
function generate_fibonacci(
    p_length in pls_integer) return xtras_numbers_t pipelined;

end xtras_generators;
/
