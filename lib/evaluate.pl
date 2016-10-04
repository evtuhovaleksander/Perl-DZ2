
=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
use DDP;

BEGIN {
    if ( $] < 5.018 ) {

        package experimental;
        use warnings::register;
    }
}
no warnings 'experimental';

sub evaluate {
    my $rpn   = shift;
    my @stack = ();
    my @token = @{$rpn};
	# print @token;

    my $res;
    for (@token) {
		given ($_) {
	        when ( $_ eq "U-" ) {
	            my $x = pop(@stack);
	            push( @stack, -$x );
	        }
	        when ( $_ eq "U+" ) {
	            my $x = pop(@stack);
	            push( @stack, $x );
	        }
	        when ( $_ =~ /[\+\-\*\/\^]/ ) {
	            if ( scalar(@stack) < 2 ) {
	                die 'NaN';
					exit;
	            }
	            my $x = pop(@stack);
	            my $y = pop(@stack);
	            given ($_) {
				    when ( $_ eq '*' ) {
			            $res = $y * $x;
			        }
			        when ( $_ eq '/' ) {
			            $res = $y / $x;
			        }
			        when ( $_ eq '+' ) {
			            $res = $y + $x;
			        }
			        when ( $_ eq '-' ) {
			            $res = $y - $x;
			        }
			        when ( $_ eq '^' ) {
			            $res = $y ** $x;
			        }
					default {
						die 'NaN';
						exit;
					}
			    }

	            push( @stack, $res );
	        }
	        when ( $_ =~ /[0-9]/ ) {
	            push( @stack, $_ );
	        }
	        default {
	            die 'NaN';
				exit;
	        }
	    }
		# p $stack[-1];
	}
    if ( (@stack > 1) or (!($stack[-1]))) ) {
        die 'NaN';
		exit;
    }
    # print( pop(@stack) );
	# my $t = pop(@stack);
	# p $t;
    # return pop(@stack);
	return pop(@stack);
}

1;
