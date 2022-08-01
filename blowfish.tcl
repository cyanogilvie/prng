package require prng
package require sha1
package require crypto
namespace eval prng::blowfish {}

oo::class create prng::blowfish::_base { #<<<
	superclass prng::_baseseq

	variable {*}{
		P
		S
		pos
		ivl
		ivr
		O
	}

	constructor {} { #<<<
		if {[self next] ne ""} next
		package require crypto
	}

	#>>>
	method random_bytes count { #<<<
		while {[string length $O] < $count} {
			set pos	[expr {($pos + 1) & 0xffffffffffffffff}]
			set l	[expr {(($pos >> 32) & 0xffffffff) ^ $ivl}]
			set r	[expr {( $pos        & 0xffffffff) ^ $ivr}]

			lassign [crypto::blowfish::_transform_block $P $S $l $r] l r
			set ivl	$l
			set ivr	$r
			append O	[binary format II $l $r]
		}
		set res	[string range $O 0 $count-1]
		set O	[string range $O $count end]
		set res
	}

	#>>>
	method save_state {} {list $pos $ivl $ivr $O}
	method restore_state saved_state {lassign $saved_state pos ivl ivr O}
	method subsequence {{name ""}} { #<<<
		if {$name eq ""} {
			prng::Subsequence new $P $S [list \
					[my random_uint64] \
					[my random_uint32] \
					[my random_uint32] \
					""]
		} else {
			uplevel 1 [list \
				prng::Subsequence create $name $P $S [list \
						[my random_uint64] \
						[my random_uint32] \
						[my random_uint32] \
						""] \
			]
		}
	}

	#>>>
}

#>>>
oo::class create prng::Sequence { #<<<
	superclass prng::blowfish::_base

	variable {*}{
		P
		S
		pos
		ivl
		ivr
		O
	}

	constructor seed { #<<<
		next
		namespace path [concat [namespace path] {
			::tcl::mathop
			::tcl::mathfunc
		}]
		package require sha1

		set csprngstate	[dict create]
		set eseed	[my _expand_seed $seed]
		lassign [crypto::blowfish::init_key [string range $eseed 0 55]] P S
		binary scan [string range $eseed 56 63] W pos
		binary scan [string range $eseed 64 71] II ivl ivr
		set O	""
	}

	#>>>
	method _expand_seed seed { #<<<
		set res	""
		append res	[sha1::sha1 -bin $seed$res]
		append res	[sha1::sha1 -bin $seed$res]
		append res	[sha1::sha1 -bin $seed$res]
		append res	[sha1::sha1 -bin $seed$res]
		string range $res 0 71
	}

	#>>>
}

#>>>
oo::class create prng::Subsequence { #<<<
	superclass prng::blowfish::_base

	variable {*}{
		P
		S
	}

	constructor {a_P a_S state} { #<<<
		next
		namespace path [concat [namespace path] {
			::tcl::mathop
			::tcl::mathfunc
		}]
		set P	$a_P
		set S	$a_S
		my restore_state $state
	}

	#>>>
}

#>>>

# vim: ft=tcl foldmethod=marker foldmarker=<<<,>>> ts=4 shiftwidth=4
