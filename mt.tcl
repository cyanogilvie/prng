#
# ----------------------------------------------------------------------
# Mersenne Twister Random Number Generator
#
# Derived from the source code for MT19937 by Takuji Nishimura
# and Makoto Matsumoto, which is available from their homepage
# at http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
#
# Written by Frank Pilhofer. Released under BSD license.
#
# Retrieved from http://wiki.tcl.tk/13121 and converted to a TclOO object
# with minor tweaks by Cyan Ogilvie
# ----------------------------------------------------------------------
#

package require prng

namespace eval ::prng::mt {}

oo::class create prng::mt::Sequence {
	superclass prng::_baseseq

	variable {*}{
		N
		M
		MATRIX_A
		UPPER_MASK
		LOWER_MASK
		mag010
		mag011
		mt
		mti

		O
	}

	constructor seed { #<<<
		if {[self next] ne ""} next

		if {"::tcl::mathop" ni [namespace path]} {
			namespace path [concat [namespace path] ::tcl::mathop]
		}

		set N			624
		set M			397
		set MATRIX_A	0x9908b0df
		set UPPER_MASK	0x80000000
		set LOWER_MASK	0x7fffffff
		set mag010		0
		set mag011		$MATRIX_A

		set O			""

		my _init $seed
	}

	#>>>

	method _seed s { # Initializes with a seed <<<
		set mt		[& $s 0xffffffff]
		set mtimm	$mt

		for {set mti 1} {$mti < $N} {incr mti} {
			set t1		[expr {$mtimm ^ ($mtimm >> 30)}]
			set t2		[expr {1812433253 * $t1 + $mti}]
			set mtimm	[& $t2 0xffffffff]
			lappend mt $mtimm
		}
	}

	#>>>
	method _init s { # Initialize from a (binary) seed string <<<
		my _seed	19650218

		set i	1
		set j	0

		#
		# The algorithm wants a list of 32 bit integers for the key
		#

		set slen	[string length $s]

		if {($slen % 4) != 0} {
			append s [string repeat "\0" [expr {4-($slen%4)}]]
		}

		binary scan $s i* key

		set mtimm	[lindex $mt 0]

		set k [tcl::mathfunc::min $N [llength $key]]
		for {} {$k} {incr k -1} {
			set keyj	[lindex $key $j]
			set mti		[lindex $mt $i]
			set t1		[expr {$mtimm ^ ($mtimm >> 30)}]
			set t2		[expr {$mti ^ ($t1 * 1664525)}]
			set t3		[+ $t2 $keyj $j]
			set mtimm	[& $t3 0xffffffff]
			lset mt $i	$mtimm
			incr i
			incr j
			if {$i >= $N} {
				lset mt 0	$mtimm
				set i		1
			}
			if {$j >= [llength $key]} {
				set j		0
			}
		}

		for {set k 1} {$k < $N} {incr k} {
			set mti		[lindex $mt $i]
			set t1		[expr {$mtimm ^ ($mtimm >> 30)}]
			set t2		[expr {$mti ^ ($t1 * 1566083941)}]
			set t3		[- $t2 $i]
			set mtimm	[& $t3 0xffffffff]
			lset mt $i	$mtimm
			incr i
			if {$i >= $N} {
				lset mt 0	$mtimm
				set i		1
			}
		}

		lset mt 0 0x80000000
	}

	#>>>
	method _more {} { # Produce some more random numbers <<<
		set newmt	{}

		for {set kk 0} {$kk < $N - $M} {incr kk} {
			set mtkk	[lindex $mt $kk]
			set mtkkpp	[lindex $mt [+ $kk 1]]
			set mtkkpm	[lindex $mt [+ $kk $M]]
			set y		[expr {($mtkk & $UPPER_MASK) | ($mtkkpp & $LOWER_MASK)}]
			if {($y & 1) == 0} {
				set mag01	$mag010
			} else {
				set mag01	$mag011
			}
			set mtkk	[expr {$mtkkpm ^ ($y >> 1) ^ $mag01}]
			lappend newmt $mtkk
		}
		for {} {$kk < $N - 1} {incr kk} {
			set mtkk	[lindex $mt $kk]
			set mtkkpp	[lindex $mt [+ $kk 1]]
			set mtkkpm	[lindex $newmt [+ $kk $M -$N]]
			set y		[expr {($mtkk & $UPPER_MASK) | ($mtkkpp & $LOWER_MASK)}]
			if {($y & 1) == 0} {
				set mag01	$mag010
			} else {
				set mag01	$mag011
			}
			set mtkk	[expr {$mtkkpm ^ ($y >> 1) ^ $mag01}]
			lappend newmt $mtkk
		}
		set mtnm1	[lindex $mt [- $N 1]]
		set mt0		[lindex $newmt 0]
		set mtmmm	[lindex $newmt [- $M 1]]
		set y		[expr {($mtnm1 & $UPPER_MASK) | ($mt0 & $LOWER_MASK)}]
		if {($y & 1) == 0} {
			set mag01	$mag010
		} else {
			set mag01	$mag011
		}
		set mtkk	[expr {$mtmmm ^ ($y >> 1) ^ $mag01}]
		lappend newmt $mtkk

		set mti	0
		set mt	$newmt
	}

	#>>>

	method mt_uint32 {} { # Generates an integer random number in the [0,0xffffffff] interval <<<
		if {$mti >= $N} {
			my _more
		}

		set y	[lindex $mt $mti]
		incr mti

		set y	[expr {$y ^  ($y >> 11)}]
		set y	[expr {$y ^ (($y <<  7) & 0x9d2c5680)}]
		set y	[expr {$y ^ (($y << 15) & 0xefc60000)}]
		set y	[expr {$y ^  ($y >> 18)}]

		& $y 0xffffffff
	}

	#>>>
	method mt_rand {} { # Generates a floating-point random number in the [0,1) interval <<<
		/ [my mt_uint32] 4294967296.0
	}

	#>>>

	method random_bytes count { #<<<
		# Return a bytearray of $count random bytes

		while {[string length $O] < $count} {
			append O	[binary format I [my mt_uint32]]
		}
		set res	[string range $O 0 $count-1]
		set O	[string range $O $count end]
		set res
	}

	#>>>
	method save_state {} {list $mt $mti}
	method restore_state saved_state {lassign $saved_state mt mti}
	method subsequence {{name ""}} { #<<<
		set bytes	[expr {int(ceil($N / 8.0))}]
		set ints	{}
		for {set i 0} {$i < $bytes} {incr i} {
			lappend ints	[my mt_uint32]
		}
		set newseed	[binary format mu* {*}$ints]
		if {$name eq ""} {
			prng::mt::Sequence new $newseed
		} else {
			uplevel 1 [list \
				prng::mt::Sequence create $name $newseed
			]
		}
	}

	#>>>
}

# ----------------------------------------------------------------------
# Print test vectors, for comparison with the original code
# ----------------------------------------------------------------------

proc prng::mt::test {} { #<<<
	prng::mt::Sequence create s [binary format i4 {0x123 0x234 0x345 0x456}]
	puts {1000 outputs of mt_uint32}
	for {set i 0} {$i < 1000} {incr i} {
		puts -nonewline [format {%10u } [s mt_uint32]]
		if {($i % 5) == 4} {
			puts {}
		}
	}
	puts {1000 outputs of mt_rand}
	for {set i 0} {$i < 1000} {incr i} {
		puts -nonewline [format {%10.8f } [s mt_rand]]
		if {($i % 5) == 4} {
			puts {}
		}
	}
}

#>>>

# vim: ft=tcl foldmethod=marker foldmarker=<<<,>>> ts=4 shiftwidth=4
