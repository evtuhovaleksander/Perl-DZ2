=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub evaluate {

	my @stack = ();
    my $temp = shift;
	my @token = @{$temp};
	my $res;
	for (@token)
	{
		if ($_ eq "U-") {
			my $x = pop(@stack);
			push(@stack, -$x);
        }
		elsif ($_ eq "U+") {
			my $x = pop(@stack);
			if ($x<0) {
			push(@stack, -$x);
			}
			else{
				push(@stack, $x);
			}
        }
		elsif ($_ =~ /[\+\-\*\/\^]/)
		{
			if (scalar(@stack) < 2)
				{
					print "îøèáêà";
				}
			my $x = pop(@stack);
			my $y = pop(@stack);
			if ($_ eq '*')
			{
				$res = $y*$x;
			}
			elsif($_ eq '/')
			{
				$res = $y/$x;
			}
			elsif($_ eq '+')
			{
				$res = $y+$x;
			}
			elsif($_ eq '-')
			{
				$res = $y-$x;
			}
			elsif($_ eq '^')
			{
				$res = $y**$x;
			}
			push(@stack, $res);
		} elsif ($_ =~ /[0-9]/)
		{
			push(@stack, $_);
		} else
		{
			print "íåäîïóñòèìûé ñèìâîë";
		}

	}
	if (scalar(@stack) > 1)
	{
		print("Êîëè÷åñòâî îïåðàòîðîâ íå ñîîòâåòñòâóåò êîëè÷åñòâó îïåðàíäîâ");
	}
	return pop(@stack);
}

1;
