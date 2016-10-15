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
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {

	my @stack=(); #îáúÿâëÿåì ìàññèâ ñòåêà
        my @out=(); #îáúÿâëÿåì ìàññèâ âûõîäíîé ñòðîêè

        my %prior = ( #çàäàåì ïðèîðèòåò îïåðàòîðîâ, à òàêæå èõ àññîöèàòèâíîñòü
			"U-" => {"prior" => "5", "assoc" => "right"},
            "U+" => {"prior" => "5", "assoc" => "right"},
            "^"=> {"prior" => "4", "assoc" => "right"},
			"*"=> {"prior" => "3", "assoc" => "left"},
			"/"=> {"prior" => "3", "assoc" => "left"},
			"+"=> {"prior" => "2", "assoc" => "left"},
			"-"=> {"prior" => "2", "assoc" => "left"},
	);
	my $expr = shift;

	my @token = @{tokenize($expr)};
	if((scalar @token) ==0) {die ""; exit;}
	my @rpn;


	my $endop;
    	my $curr_assoc;
    	my $curr_prior;
    	my $may_unary= 1;
    	my $lastnum = 0;

	foreach (@token)
	{
        my $value = $_;

		if ($value =~ /[\+\-\*\/\^#]/) #åñëè âñòðåòèëè îïåðàòîð
			{
				# ÝÒÎ ÏÎËÍÀß ÕÅÐÍß îòíûíå !=U+ #=U-
                #if ($may_unary&&$value eq "#") { #åñëè óíàðíèê - ÕÅÐÍß
                #    $value = "U-";
                #}
				if ($may_unary&&$value eq "-") { #åñëè óíàðíèê - ÕÅÐÍß
                    $value = "U-";
                }
                if ($may_unary&&$value eq "+") {
                    $value = "U+";
               }

				$endop = 0; #ìàðêåð êîíöà öèêëà ðàçáîðà îïåðàòîðîâ

				while ($endop != 1)
				{
					my $lastop = pop(@stack);
					if(!defined($lastop)){$lastop="";}
					if ($lastop eq "")
					{
                            push(@stack,$value); #åñëè â ñòåêå íåò îïåðàòîðîâ - ïðîñòî çàïèñûâàåì òåêóùèé îïåðàòîð â ñòåê
                            $endop = 1; #óêàæåì, ÷òî öèêë ðàçáîðà while çàêîí÷èëñ
					}
					else #åñëè â ñòåêå åñòü îïåðàòîðû - òî ïîñëåäíèé ñåé÷àñ â ïåðåìåííî
					{
						# ïîëó÷èì ïðèîðèòåò è àññîöèàòèâíîñòü òåêóùåãî îïåðàòîðà è ñðàâíèì åãî ñ
						$curr_prior = $prior{$value}->{'prior'}; #ïðèîðèòåò òåêóùèåãî îïåðàòîðà
						$curr_assoc = $prior{$value}->{'assoc'}; #àññîöèàòèâíîñòü òåêóùèåãî îïåðàòîðà

						my $prev_prior = $prior{$lastop}->{'prior'}; #ïðèîðèòåò ïðåäûäóùåãî îïåðàòîðà
							if(!defined($prev_prior)){$prev_prior=1;}
						if ($curr_assoc eq "left")
                        {   #îïåðàòîð - ëåâî-àññîöèàòèâíûé

									if ($curr_prior > $prev_prior) #åñëè ïðèîðèòåò òåêóùåãî îïåðòîðà áîëüøå ïðåäûäóùåãî, òî çàïèñûâàåì â ñòåê ïðåäûäóùèé, ïîòîì òåêéùèé
                                    {
                                        push(@stack,$lastop);
                                    	push(@stack,$value);
                                        $endop = 1; #óêàæåì, ÷òî öèêë ðàçáîðà îïåðàòîðîâ while çàêîí÷èëñÿ
                                    }

									elsif($curr_prior <= $prev_prior)#åñëè òåê. ïðèîðèòåò ìåíüøå èëè ðàâåí ïðåä. - âûòàëêèâàåì ïðåä. â ñòðîêó out[]
									{
                                            push(@out,$lastop);
                                    }
						}
						elsif ($curr_assoc eq "right")#îïåðàòîð - ïðàâî-àññîöèàòèâíûé
						{
									if ($curr_prior >= $prev_prior) #åñëè ïðèîðèòåò òåêóùåãî îïåðòîðà áîëüøå èëè ðàâåí ïðåäûäóùåãî, òî çàïèñûâàåì â ñòåê ïðåäûäóùèé, ïîòîì òåêéùèé
									{
                                            push(@stack,$lastop);
                                            push(@stack,$value);
                                            $endop = 1; #óêàæåì, ÷òî öèêë ðàçáîðà îïåðàòîðîâ while çàêîí÷èëñÿ
                                    }

									elsif ($curr_prior < $prev_prior) #åñëè òåê. ïðèîðèòåò ìåíüøå ïðåä. - âûòàëêèâàåì ïðåä. â ñòðîêó out[]
									{
                                        push(@out,$lastop);
                                    }
						}

                    }



                } #while ($endop != TRUE)
				$lastnum = 0; #óêàæåì, ÷òî ïîñëåäíèé ðàçîáðàííûé ñèìâîë - íå öèôðà
                $may_unary= 1;
		}
		elsif ($value =~ /[0-9\.]/) #âñòðåòèëè öèôðó èëè òî÷êó
			{

		#Ìû âñòðåòèëè öèôðó èëè òî÷êó (äðîáíîå ÷èñëî). Íàäî ïîíÿòü, êàêîé ñèìâîë áûë ðàçîáðàí ïåðåä íåé.
		#Çà ýòî îòâå÷àåò ïåðåìåííàÿ $lastnum - åñëè îíà TRUE, òî ïîñëåäíåé áûëà öèôðà.
		#Â ýòîì ñëó÷àå íàäî äîïèñàòü òåêóùóþ öèôðó ê ïîñëåäíåìó ýëìåíòó ìàññèâà âûõîäíîé ñòðîêè*/
				if ($lastnum == 1)  #ðàçîáðàííûé ñèìâîë - öèôðà
					{
						my $num = pop(@out); #èçâëå÷åì ñîäåðæèìîå ïîñëåäíåãî ýëåìåíòà ìàññèâà ñòðîêè
						push(@out,$num.$value);
					}

				else
					{
						push(@out,$value); #åñëè ïîñëåäíèì áûë çíàê îïåðàöèè - òî îòêðûâàåì íîâûé ýëåìåíò ìàññèâà ñòðîêè
						$lastnum = 1; #è óêàçûâàåì, ÷òî ïîñëåäíèì áûëà öèôðà
					}
                    $may_unary = 0;
			}

		elsif ($value eq "(") #âñòðåèëè ñêîáêó ÎÒêðûâàþùóþ
			{
		#Ìû âñòðåòèëè ÎÒêðûâàþùóþ ñêîáêó - íàäî ïðîñòî ïîìåñòèòü åå â ñòåê*/
						push(@stack,$value);
						$lastnum = 0; # óêàçûâàåì, ÷òî ïîñëåäíèì áûëà ÍÅ öèôðà
                $may_unary = 1;
            }

		elsif ($value eq ")") #âñòðåèëè ñêîáêó ÇÀêðûâàþùóþ
			{

		#Ìû âñòðåòèëè ÇÀêðûâàþùóþ ñêîáêó - òåïåðü âûòàëêèâàåì ñ âåðøèíû ñòåêà â ñòðîêó âñå îïåðàòîðû, ïîêà íå âñòðåòèì ÎÒêðûâàþùóþ ñêîáêó*/
						my $skobka = 0; #ìàðêåð íàõîæäåíèÿ îòêðûâàþùåé ñêîáêè
						while ($skobka != 1) #ïîêà íå íàéäåì â ñòåêå ÎÒêðûâàþùóþ ñêîáêó
						{
							my $op = pop(@stack); #áåðåì îïåðàòîðà ñ âåðøèíû ñòåêà

								if ($op eq "(")
								{
									$skobka = 1;
								}

								else
								{
									push(@out,$op);
								}


						}

						$lastnum = 0;
            $may_unary = 0;
			}

	}

	@rpn = @out;

	while (my $stack_el = pop(@stack))
	{
		push(@rpn,$stack_el);
	}

	my $rpn_str;
    for(@rpn){
        $rpn_str.="$_ ";
    }

    chop($rpn_str);
	@rpn = split/\s/,$rpn_str;


	for (my $var = 0; $var < (scalar @rpn)-1; $var++) {
			#if($rpn[$var]=="U+"&&$rpn[$var+1]=="U+"){die ""; exit;}
			if($rpn[$var] eq "U-"&&$rpn[$var+1] eq "U-"){die ""; exit;}
			#if($rpn[$var]=="U+"&&$rpn[$var+1]=="U-"){die ""; exit;}
			#if($rpn[$var]=="U-"&&$rpn[$var+1]=="U+"){die ""; exit;}
	}



	return \@rpn;

}
1;
