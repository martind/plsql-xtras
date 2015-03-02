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

-- Generate prime numbers in a range
-- Segmented sieve of Eratosthenes used to find primes in range [a, b]

-- Steps
-- 1) find all the primes up to sqrt(b), call them primes[]
-- 2) create a boolean array is_prime[] with length = b-a+1 and fill it with true
-- 3) for each p in primes set is_prime[i*p - a] = false starting at i=ceil(a/p)
-- 4) for each is_prime[i]=true print i+a
function generate_primes(
    p_min in number,
    p_max in number,
    p_segment_size number := 32000) return xtras_numbers_t deterministic pipelined
as
    type primes_t is table of number;
    type bool_primes_t is table of boolean;
    
    primes primes_t := primes_t();
    is_prime bool_primes_t;
    
    seed_primes_size number := ceil(sqrt(p_max));
begin
    -- checking bogus parameters
    if (p_min is null) or 
       (p_max is null) or 
       (p_max <= p_min) or 
       (p_segment_size is null) or
       (p_segment_size <= 0) 
    then
        return;
    end if;
    
    -- find all the primes up to sqrt(p_max)
    is_prime := bool_primes_t();
    is_prime.extend(seed_primes_size);
    for i in 1 .. is_prime.count loop
        is_prime(i) := true;
    end loop;
    
    for i in 2 .. seed_primes_size loop
        if is_prime(i) then
            primes.extend;
            primes(primes.last) := i;
            
            declare
                j pls_integer := i * i;
            begin
                while j <= seed_primes_size loop
                    is_prime(j) := false;
                    j := j + i;
                end loop;
            end;
        end if;
    end loop;
    
    -- if the requested range is overlapping with the seeding primes, pipe them
    -- before they are marked as non-prime in the next cycle
    if p_min <= seed_primes_size then
        for prime_idx in 1 .. primes.count loop
            if primes(prime_idx) >= p_min then
                pipe row (primes(prime_idx));
            end if;
        end loop;
    end if;
    
    -- for each p in primes set is_prime[i*p - p_min] = false starting at i=ceil(p_min/p)
    -- we also split the original range in subranges so that we don't allocate too much memory
    declare
        l_segment_min number := p_min;
        l_segment_max number := least(l_segment_min + p_segment_size - 1, p_max);
    begin
        loop
            is_prime := bool_primes_t();
            is_prime.extend(l_segment_max - l_segment_min);
            for i in 1 .. is_prime.count loop
                is_prime(i) := true;
            end loop;
            
            for prime_idx in 1 .. primes.count loop
                declare
                    prime number := primes(prime_idx);
                    i pls_integer := ceil(l_segment_min / prime);
                    next_idx pls_integer := i * prime - l_segment_min + 1;
                begin
                    while next_idx <= is_prime.count loop
                        is_prime(next_idx) := false;
                        next_idx := next_idx + prime;
                    end loop;
                end;
            end loop;
            
            -- for each is_prime[i]=true print i+l_segment_min
            for i in 1 .. is_prime.count loop
                if is_prime(i) and l_segment_min + i - 1 > 1 then
                    pipe row (l_segment_min + i - 1);
                end if;
            end loop;
            
            l_segment_min := l_segment_max + 1;
            l_segment_max := least(l_segment_min + p_segment_size - 1, p_max);
            exit when l_segment_min >= p_max;
        end loop;
    end;
end generate_primes;

end xtras_generators;
/
