# PL/SQL Xtras Utilities

This is a small collections of utilities for Oracle PL/SQL I could not find elsewhere.

**Code is currently in alpha stage.**

## Installation

TODO

## Usage

### Generators

The `xtras_generators` package contains a collection of table functions that generate data, in the same vein of `generate_series` functions in PostgreSQL.

Examples:

* Get 10 random numbers between 0 and 1

```
select *
  from table(xtras_generators.generate_random_numbers(10))
```

* Get 10 random integers between 1 and 100

```
select trunc(column_value)
  from table(xtras_generators.generate_random_numbers(10, 1, 100))
```

* Get 10 random hexadecimal strings of 30 characters

```
select *
  from table(xtras_generators.generate_random_strings(10, 'x', 30))
```

* Generate a series of numbers

```
select *
  from table(xtras_generators.generate_series(1, 10))

select *
  from table(xtras_generators.generate_series(5, -5, -2))
```

* Generate a series of timestamps

```
select t.column_value
  from table(xtras_generators.generate_series(to_timestamp('2015-01-01', 'yyyy-mm-dd'),
                                              to_timestamp('2015-01-15', 'yyyy-mm-dd'),
                                              interval '1' day)) t
```

* Generate the first 30 fibonacci numbers

```
select *
  from table(xtras_generators.generate_fibonacci(30))
```

* Generate all prime numbers between 1000 and 5000

```
select *
  from table(xtras_generators.generate_primes(1000, 5000))
```
