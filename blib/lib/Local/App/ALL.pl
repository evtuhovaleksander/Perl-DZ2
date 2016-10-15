use strict;
use Data::Dumper;
use feature 'say';
my $expr = "- 16 + 2 * 0.3e+2 - .5 ^ ( 2 - 3 )";

sub tokenize {
	chomp(my $expr = shift);
	say "|".$expr."|";
    $expr=" ".$expr." ";
    say "|".$expr."|";
	#âîçìîæíûå ïîäñòàíîâêè óíàðíûõ îïåðàòîðîâ -
	#*-
	#+-
	#/-
	#^-
	#(-
	#begin-
	#$expr=~s/\+\-/\+#/;

	#âîçìîæíûå ïîäñòàíîâêè óíàðíûõ îïåðàòîðîâ +
	#*+
	#/+
	#^+
	#-+
	#(+
	#begin+
	#$expr=~s/\+\-/\+#/;
	
	# äî ëàñòà ìåíÿåì ++ íà + è -- íà +
	#while ($expr =~ /\+\+/ ) {
    #    $expr =~ s/\+\+/\+/;
    #}
    
	#	while ($expr =~ /\-\-/ ) {
    #    $expr =~ s/\-\-/\+/;
    #}
	
	
	# ïðîâåðêà íà òðîéíîé îïåðàòîð è / èëè çàïðåùåííûå êîìáèíàöèè èç 3õ îïåðàòîðîâ
	
	
	
	
	my @temp = split//, $expr;
	my @res;
	my $str_temp = "";
	my $flag = 0;
	my $flag_e = 0;
	my $flag_was_dot=0;
	say "untoken str";
	say Dumper @temp;
	for (@temp){
		if ($_ eq " ") { #êîíåö òîêåíà ïîñëå ïðîáåëà
			if ($flag) { # åñòü îáðàáàòûâåìûé òîêåí   
				push(@res,$str_temp); # òîêåí ñðîêó ïóøèì
				$str_temp = ""; # îáíóëÿåì òîêå ñòðîêó
            }
			$flag = 0;
			$flag_e = 0; # áðîñàåì ôëàãè
        }
		elsif($_ =~ /[0-9\.e]/){ # åñëè ñèìâîë èç ïåðå÷èñëåíèÿ
			if ($_ eq "e") { # åñëè å
                $flag_e = 1; # ôëàã áûëî å â 1
            }
			elsif($_ =~ /[0-9]/) {$flag_e =0;}
			if(($_ eq ".")&&$flag_was_dot)
			{
				die "double dot token"; print "double dot token";
			}
			if (($_ eq ".")&&!$flag_was_dot) {
                $flag_was_dot=1;
            }
		#	if(($_ eq "/.")&&$flag_was_dot){print "double dot token"; }
            
			$flag = 1; # íà÷àëî òîêåíà â 1
			$str_temp.=$_; # ïóøèì â áóôåð òîêåíà ñèìâîë
		}
		elsif($_ =~ /[\+\-\*\/\^\(\)# ]/){ # åñëè îïåðàòîð
			if ($flag_e&&$_ eq "+") { # åñëè ïîñëå å èäåò ïëþñ
                $str_temp.=$_; # ïóøèì â òîêåí
				$flag_e = 0; # íóëèì ôëàã áûëî å
            }
			else{
				if ($flag) { # åñëè ïðîñòî áûë òîêåí
				push(@res,$str_temp); # çàâåðøàåì òîêå è ïóøèì â ðåçðîëò
				$str_temp = ""; # íóëèì
				$flag = 0; # íóëèì
				 $flag_was_dot=0;
				}
				push(@res,$_);
				
			}
		}
	}
	
   	for(@res){
        	if ($_ =~ /[\.e]/){
			$_ = 0+$_;  # åñëè òîêåí âèäà .5 òî ïëþóåì ê íà÷àëó 0
        	}
    	}
	
	say "token str";
	say Dumper @res;
	return \@res;
}

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
					if ($lastop eq "")
					{
                            push(@stack,$value); #åñëè â ñòåêå íåò îïåðàòîðîâ - ïðîñòî çàïèñûâàåì òåêóùèé îïåðàòîð â ñòåê
                            $endop = 1; #óêàæåì, ÷òî öèêë ðàçáîðà while çàêîí÷èëñ
					}					
					else #åñëè â ñòåêå åñòü îïåðàòîðû - òî ïîñëåäíèé ñåé÷àñ â ïåðåìåííîé $lastop
					{
						# ïîëó÷èì ïðèîðèòåò è àññîöèàòèâíîñòü òåêóùåãî îïåðàòîðà è ñðàâíèì åãî ñ $lastop 
						$curr_prior = $prior{$value}->{'prior'}; #ïðèîðèòåò òåêóùèåãî îïåðàòîðà
						$curr_assoc = $prior{$value}->{'assoc'}; #àññîöèàòèâíîñòü òåêóùèåãî îïåðàòîðà
						
						my $prev_prior = $prior{$lastop}->{'prior'}; #ïðèîðèòåò ïðåäûäóùåãî îïåðàòîðà
		
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
									$skobka = 1; #åñëè âñòðåòèëè îòêðûâàþùóþ - ìåíÿåì ìàðêåð
								} 
								
								else
								{
									push(@out,$op); #åñëè ýòî íå ñêîáêà - îòïðàâëÿåì ñèìâîë â ñòðîêó
								}
							
								
						}
						
						$lastnum = 0; #óêàçûâàåì, ÷òî ïîñëåäíèì áûëà ÍÅ öèôðà
                        $may_unary = 0;
			}	
	
	}
	#foreach çàêîí÷èëñÿ - ìû ðàçîáðàëè âñå âûðàæåíèå
	#òåïåðü âûòîëêíåì âñå îñòàâøèåñÿ ýëåìåíòû ñòåêà â âûõîäíóþ ñòðîêó, íà÷èíàÿ ñ âåðøèíû ñòåêà*/

	#$stack1 = $stack; //âðåìåííûé ìàññèâ, êîïèÿ ñòåêà, íà ñëó÷àé, åñëè áóäåò íóæåí ñàì ñòåê äëÿ äåáàãà
	@rpn = @out; #íà÷èíàåì ôîðìèðîâàòü èòîãîâóþ ñòðîêó
	
	while (my $stack_el = pop(@stack))
	{
		push(@rpn,$stack_el);
	}
	
	my $rpn_str;
    for(@rpn){
        $rpn_str.="$_ ";
    }
    #çàïèøåì èòîãîâûé ìàññèâ â ñòðîêó
    chop($rpn_str);
	@rpn = split/\s/,$rpn_str; #ôóíêöèÿ âîçâðàùàåò ñòðîêó, â êîòîðîé èñõîäíîå âûðàæåíèå ïðåäñòàâëåíî â ÎÏÇ
	say "tokenized zpm";
	say $rpn_str;

	
	return \@rpn;
}















sub calc
{
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
say calc(rpn("1 + .5e-1"));