
=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;

BEGIN {
    if ( $] < 5.018 ) {

        package experimental;
        use warnings::register;
    }
}
no warnings 'experimental';
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
    my $expr   = shift;
    my @source = @{tokenize($expr)};

    my @stack;
    my @rpn;

    my $value = "";

    my %operators = (
        "U-" => { "precedence" => "5", "associativity" => "right" },
        "U+" => { "precedence" => "5", "associativity" => "right" },
        "^"  => { "precedence" => "4", "associativity" => "right" },
        "*"  => { "precedence" => "3", "associativity" => "left" },
        "/"  => { "precedence" => "3", "associativity" => "left" },
        "+"  => { "precedence" => "2", "associativity" => "left" },
        "-"  => { "precedence" => "2", "associativity" => "left" },
    );

    for (@source) {
        given ($_) {
            when ( $_ =~ m/\d+\.?\d*/ ) {
                push(@rpn, $_);
            }
            when ( $_ =~ m/^[\(]$/ ) {
                push(@stack, $_);
            }
            when ( $_ =~ m/^[\)]$/ ) {
                while ( $stack[-1] !~ m/^[\(]$/ ) {
                    push(@rpn, pop(@stack));
                }
                pop(@stack);
            }
            when ( $_ =~ m/^(U[\+\-]|[\+\-\*\/\^])$/ ) {
                while (
                        (
                            (
                                @stack
                            )
                            and
                            (
                                $stack[-1] =~ m/^(U[\+\-]|[\+\-\*\/\^])$/
                            )
                        )
                        and
                        (
                            (
                                ($operators{$_}->{"associativity"} eq "left") and
                                ($operators{$_}->{"precedence"} <= $operators{$stack[-1]}->{"precedence"})
                            )
                            or
                            (
                                ($operators{$_}->{"associativity"} eq "right") and
                                ($operators{$_}->{"precedence"} < $operators{$stack[-1]}->{"precedence"})
                            )
                        )
                ) {
                    push(@rpn, pop(@stack));
                };
                push(@stack, $_);
            }
        }
    }
    while (@stack) {
        push(@rpn, pop(@stack));
    }

    return \@rpn;
}

1;
