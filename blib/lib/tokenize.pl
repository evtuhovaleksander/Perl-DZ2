
=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

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

sub tokenize {
    chomp( my $expr = shift );
    my @source = grep ( !m/^(\s*|)$/, split m{
            (
                (?<!e) [+-]
                |
                [*()/^]
                |
                \s+
            )
        }x, $expr );
    my @result;

    my $parenthes = 0;
    my $operators = 0;
    my $numbers = 0;
    my $previous = "";
    my $previous_type = "";

    for (@source) {
        if ( $_ =~ m/^[-+]$/ and $previous =~ m/^((\(|\s|)|([\+\-\/\*\(]))$/ ) {
            $previous_type = "unary operator";
            push( @result, "U" . $_ );
        }
        elsif ( $_ =~ m/^\d+$/ ) {
            $numbers += 1;
            $previous_type = "number";
            push( @result, "" . $_ )
        }
        elsif ( $_ =~ m/(\d*\.?\d+(e?[-+]?\d+)|(\d+))/ ) {
            $numbers += 1;
            $previous_type = "number";
            push( @result,  sprintf("%g", $_) );
        }
        else {
            $previous_type = ( $_ =~ m/^([\+\-\*\/\^])$/ ? "operator" : "parenthes" );
            $operators += ( $_ =~ m/^([\+\-\*\/\^])$/ ? 1 : 0 );
            $parenthes += ( $_ =~ m/^\($/ ? 1 : ( $_ =~ m/^\)$/ ? -1 : 0 ) );
            push( @result, $_ );
        }
        $previous = $_;
    }

    if ( !$numbers ) {
        die "Ты пидор";
    }

    if ( $parenthes ) {
        die "Ты пидор!";
    }

    if (!($numbers == $operators + 1)) {
        die "Ты ебанутый?"
    };

    return \@result;
}

1;
