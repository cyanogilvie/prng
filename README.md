# NAME

prng - Pseudorandom number and sequence utilities

# SYNOPSIS

**package require prng** ?0.6?

**package require prng::blowfish** ?0.6?

**package require prng::mt** ?0.6?

**prng::Sequence create** *seqname* *seed*

**prng::mt::Sequence create** *seqname* *seed*

*seqname* **random\_uint32**

*seqname* **random\_uint64**

*seqname* **random\_number\_norm**

*seqname* **random\_number\_halfopen**

*seqname* **random\_number\_exponential** *max*

*seqname* **random\_int** *inc\_bot* *inc\_top*

*seqname* **random\_sort** *list*

*seqname* **random\_pick** *list* ?*count*?

*seqname* **random\_normal** *mean* *stddev* ?*number*?

*seqname* **random\_exponential** *mean*

*seqname* **random\_gauss**

*seqname* **push\_state**

*seqname* **pop\_state**

*seqname* **random\_bytes** *count*

*seqname* **save\_state**

*seqname* **restore\_state** *saved\_state*

*seqname* **subsequence** ?*name*?

# DESCRIPTION

This module implements the abstract concept of a sequence of random
numbers (deterministic for a given seed) that can form a hierarchical
tree of sequences of arbitrary complexity. Each sequence provides
utility functions for common random number requirements: fitting common
distributions, uniform distribution across a precise range, random sorts
and other common but subtle requirements, as well as being able to save
and restore the internal state to a point in time. Two implementations
are provided, one based on a blowfish CSPRNG (which will provide
cryptographic quality pseudorandom numbers at the cost of higher
computation requirements), and the other based on a mersenne twister
RNG: MT19937 (which has a lower computation cost and good statistical
randomness but is not suitable for cryptographic purposes).

# COMMANDS

  - **prng::Sequence create** *seqname* *seed*  
    Create a new sequence accessible through the command *seqname* using
    the blowfish CSPRNG, seeded with the value *seed*, which is an
    arbitrary string of bytes.
  - **prng::mt::Sequence create** *seqname* *seed*  
    Create a new sequence accessible through the command *seqname* using
    the mersenne twister RNG, seeded with the value *seed*, which is an
    arbitrary string of bytes (but which is ideally a multiple of 4
    bytes in length). The quality of the generated random numbers is low
    if the seed has many zeros.
  - *seqname* **random\_uint32**  
    Return a random unsigned 32bit integer with uniform distribution in
    the interval \[0, 2³²).
  - *seqname* **random\_uint64**  
    Return a random unsigned 64bit integer with uniform distribution in
    the interval \[0, 2⁶⁴).
  - *seqname* **random\_number\_norm**  
    Return a floating point number with uniform distribution in the
    interval \[0, 1\] with 53 bits of precision.
  - *seqname* **random\_number\_halfopen**  
    Return a floating point number with uniform distribution in the
    interval \[0, 1) with 53 bits of precision.
  - *seqname* **random\_number\_exponential** *max*  
    TBD
  - *seqname* **random\_int** *inc\_bot* *inc\_top*  
    Return a random integer with nearly uniform distribution in the
    interval \[*inc\_bot*, *inc\_top*\].
  - *seqname* **random\_sort** *list*  
    Return *list* sorted randomly.
  - *seqname* **random\_pick** *list* ?*count*?  
    Return *count* unique elements from *list*, selected randomly.
    *list* must contain at least *count* elements. If *count* isn’t
    specified it defaults to 1.
  - *seqname* **random\_normal** *mean* *stddev*  
    Return a random floating-point number with normal distribution with
    the mean *mean* and standard deviation *stddev*.
  - *seqname* **random\_exponential** *mean*  
    TBD
  - *seqname* **random\_gauss**  
    TBD
  - *seqname* **push\_state**  
    Save the current sequence state to a stack.
  - *seqname* **pop\_state**  
    Restore the most recently saved sequence state from the stack.
  - *seqname* **random\_bytes** *count*  
    Return *count* random bytes.
  - *seqname* **save\_state**  
    Return a value that fully captures the internal state of the
    sequence, suitable for passing to **restore\_state**.
  - *seqname* **restore\_state** *saved\_state*  
    Restore the sequence internal state to what it was when
    *saved\_state* was generated by **save\_state**.
  - *seqname* **subsequence** ?*name*?  
    Branch a new sequence off of this one. The resulting sequence will
    be of the same type as the parent, with an initial state seeded from
    the parent. If *name* is supplied, it is the name of the command to
    access the new subsequence, otherwise a random name will be
    generated and returned.

# EXAMPLES

Generate some random numbers from a sequence seeded with the value
“hello, sequence”, and others from a subsequence branched off that
one.

``` tcl
package require prng
package require prng::mt

prng::mt::Sequence create s1 "hello, sequence"
puts "s1 random_uint32: [s1 random_uint32]"
puts "s1 random_uint64: [s1 random_uint64]"
puts "s1 random_normal: [s1 random_normal 10 2]"
s1 subsequence s2
puts "s2 random_uint32: [s2 random_uint32]"
puts "s2 random_uint64: [s2 random_uint64]"
puts "s2 random_normal: [s2 random_normal 10 2]"
```

produces the output:

    s1 random_uint32: 40479833
    s1 random_uint64: 2179017276762469631
    s1 random_normal: 10.488755572266877
    s2 random_uint32: 2415070459
    s2 random_uint64: 16788392099454078255
    s2 random_normal: 12.399809108073061

# LICENSE

This package Copyright 2013-2022 Cyan Ogilvie, and is made available
under the same license terms as the Tcl Core.