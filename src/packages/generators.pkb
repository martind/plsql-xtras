create or replace package body xtras_generators as

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
    p_max in number := 1) return xtras_numbers_t pipelined
as
    l_idx pls_integer := 0;
begin
    while l_idx < p_size loop
        pipe row(dbms_random.value(p_min, p_max));
        l_idx := l_idx + 1;
    end loop;
end generate_random_numbers;

-- Generate random strings
function generate_random_strings(
    p_size in number,
    p_option in char,
    p_string_len in number) return xtras_strings_t pipelined
as
    l_idx pls_integer := 0;
begin
    while l_idx < p_size loop
        pipe row(dbms_random.string(p_option, p_string_len));
        l_idx := l_idx + 1;
    end loop;
end generate_random_strings;

-- Generate series of number
function generate_series(
    p_start in pls_integer,
    p_stop in pls_integer,
    p_step in pls_integer := 1) return xtras_numbers_t pipelined
as
    l_next_value pls_integer := p_start;
begin
    if (p_start is null) or
       (p_stop is null) or
       (p_step is null) or
       (p_step > 0 and p_start > p_stop) or
       (p_step < 0 and p_start < p_stop)
    then
        return;
    end if;

    loop
        pipe row(l_next_value);
        l_next_value := l_next_value + p_step;
        if p_start < p_stop and l_next_value > p_stop then
            exit;
        elsif p_start > p_stop and l_next_value < p_stop then
            exit;
        end if;
    end loop;
end generate_series;

-- Generate series of timestamps
function generate_series(
    p_start in timestamp,
    p_stop in timestamp,
    p_step in dsinterval_unconstrained := interval '1' day) return xtras_timestamps_t pipelined
as
    l_next_value timestamp := p_start;
begin
    if (p_start is null) or
       (p_stop is null) or
       (p_step is null)
    then
        return;
    end if;

    loop
        pipe row(l_next_value);
        l_next_value := l_next_value + p_step;
        if p_start < p_stop and l_next_value > p_stop then
            exit;
        elsif p_start > p_stop and l_next_value < p_stop then
            exit;
        end if;
    end loop;
end generate_series;

-- Generate series of timestamps
function generate_series(
    p_start in timestamp,
    p_stop in timestamp,
    p_step in yminterval_unconstrained := interval '1' month) return xtras_timestamps_t pipelined
as
    l_next_value timestamp := p_start;
begin
    if (p_start is null) or
       (p_stop is null) or
       (p_step is null)
    then
        return;
    end if;

    loop
        pipe row(l_next_value);
        l_next_value := l_next_value + p_step;
        if p_start < p_stop and l_next_value > p_stop then
            exit;
        elsif p_start > p_stop and l_next_value < p_stop then
            exit;
        end if;
    end loop;
end generate_series;

-- Generate fibonacci numbers in a range
function generate_fibonacci(
    p_min in number,
    p_max in number) return xtras_numbers_t pipelined
as
    l_a number := 0;
    l_b number := 1;
    l_next number;
begin
    if p_min <= 1 then
        pipe row(1);
    end if;
    
    loop
        l_next := l_a + l_b;
        l_a := l_b;
        l_b := l_next;
        exit when l_next > p_max;
        if l_next > p_min then
            pipe row(l_next);
        end if;
    end loop;
end generate_fibonacci;

-- Generate the first N fibonacci numbers
function generate_fibonacci(
    p_length in pls_integer) return xtras_numbers_t pipelined
as
    l_a number := 0;
    l_b number := 1;
    l_next number;
    l_idx pls_integer := 0;
begin
    if p_length >= 1 then
        pipe row(1);
        l_idx := l_idx + 1;
    end if;
    
    loop
        l_next := l_a + l_b;
        l_a := l_b;
        l_b := l_next;
        l_idx := l_idx + 1;
        exit when l_idx > p_length;
        pipe row(l_next);
    end loop;
end generate_fibonacci;

end xtras_generators;
/
