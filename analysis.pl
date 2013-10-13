#!/usr/local/bin/perl -w

use strict;

use Carp;
use FileHandle;

my $neg_word = "negative-words\.txt";
my $neg_word_fh = new FileHandle $neg_word , "r"
  or croak "Failed $neg_word";

my $pos_word = "positive-words\.txt";
my $pos_word_fh = new FileHandle $pos_word , "r"
  or croak "Failed $pos_word";

my $mix_word = "subjclueslen1-HLTEMNLP05\.tff";
my $mix_word_fh = new FileHandle $mix_word , "r"
  or croak "Failed $mix_word";

my $test_twi = "TrimedTwiData\.txt";
my $test_twi_fh = new FileHandle $test_twi , "r"
  or croak "Failed $test_twi";

my $train_pos = "TrainPos\.txt";
my $train_pos_fh = new FileHandle $train_pos , "r"
  or croak "Failed $train_pos";

my $train_neg = "TrainNeg\.txt";
my $train_neg_fh = new FileHandle $train_neg , "r"
  or croak "Failed $train_neg";

my $line          = undef;
my $new_line      = undef;
my $weight        = 1;
my %neg_word_hash = ();
my %pos_word_hash = ();
my @twi_score     = ();
my @doc_count     = ();
my $time          = 0;
my $old_time      = 0;
my $doc_num       = -1;

while ( defined( $line = <$neg_word_fh> ) ) {
	if ( $line =~ /(.+)\tNEG/ ) {

		#print "$1\n";
		$neg_word_hash{$1} = $weight;
	}
}
while ( defined( $line = <$pos_word_fh> ) ) {
	if ( $line =~ /(.+)\tPOS/ ) {

		#print "$1\n";
		$pos_word_hash{$1} = $weight;
	}
}
while ( defined( $line = <$mix_word_fh> ) ) {
	if ( $line =~ /(.+)\tPOS/ ) {
		
		#print "$1\n";
		$pos_word_hash{$1} = $weight;
	}
	elsif ( $line =~ /(.+)\tNEG/ ) {
		$neg_word_hash{$1} = $weight;
	}
}

while ( defined( $line = <$train_neg_fh> ) ) {
	chomp $line;
	if ( $line ne "" ) {

		#print "$line\n";
		if ( $line =~ s/[\(\):!,@\/_\-\.;\^]+/ /g ) {

			#print "$line\n";
			chomp $line;
			my @tmp_word = split( " ", $line );

			#print scalar(@tmp_word),"++";
			foreach my $word (@tmp_word) {

				#print "--$word--";
				if ( defined $neg_word_hash{$word} ) {
					$neg_word_hash{$word} = $neg_word_hash{$word} + 1;
				}
			}
		}
	}
}
while ( defined( $line = <$train_pos_fh> ) ) {
	chomp $line;
	if ( $line ne "" ) {

		#print "$line\n";
		if ( $line =~ s/[\(\):!,@\/_\-\.;\^]+/ /g ) {

			#print "$line\n";
			chomp $line;
			my @tmp_word = split( " ", $line );

			#print scalar(@tmp_word),"++";
			foreach my $word (@tmp_word) {

				#print "--$word--";
				if ( defined $pos_word_hash{$word} ) {
					$pos_word_hash{$word} = $pos_word_hash{$word} + 1;
				}
			}
		}
	}
}

#print $neg_word_hash{"damn"};

while ( defined( $line = <$test_twi_fh> ) ) {
	chomp $line;
	if ( $line =~ /^T\.([0-9]+)/ ) {
		$time = $1;
		if ( $time ne $old_time ) {
			$doc_num = -1;
		}
		$doc_num++;
		$twi_score[$time][$doc_num] = 0;
		$doc_count[$time]           = $doc_num;
		$old_time                   = $time;
		next;
	}
	if ( defined( $neg_word_hash{$line} ) ) {
		$twi_score[$time][$doc_num] =
		  $twi_score[$time][$doc_num] - $neg_word_hash{$line};
	}
	if ( defined( $pos_word_hash{$line} ) ) {
		$twi_score[$time][$doc_num] =
		  $twi_score[$time][$doc_num] + $pos_word_hash{$line};

		#print $twi_score[$time][$doc_num];
	}
}

#print "$doc_num+$time";
#print "+$twi_score[23][0]";
#print $doc_count[13];

my @pos_count   = ();
my @neg_count   = ();
my @neual_count = ();
my $i           = 0;
my $j           = 0;
my $tmp_count   = 0;
my @comp        = ();

for ( $i = 0 ; $i < 24 ; $i++ ) {
	for ( $j = 0 ; $j < $doc_count[$i] ; $j++ ) {
		if ( $twi_score[$i][$j] > 0 ) {
			$comp[$i][0] += $twi_score[$i][$j];
		}
		if ( $twi_score[$i][$j] < 0 ) {
			$comp[$i][1] += $twi_score[$i][$j];
		}
	}
}

for ( $i = 0 ; $i < 24 ; $i++ ) {
	$pos_count[$i]   = 0;
	$neg_count[$i]   = 0;
	$neual_count[$i] = 0;
	for ( $j = 0 ; $j < $doc_count[$i] ; $j++ ) {

		#print $twi_score[$i][$j];
		if ( $twi_score[$i][$j] > 0 ) {
			$pos_count[$i]++;
		}
		if ( $twi_score[$i][$j] < 0 ) {
			$neg_count[$i]++;
		}
		if ( $twi_score[$i][$j] == 0 ) {
			$neual_count[$i]++;
		}
	}
}

#print $pos_count[0];

while (1) {

	print <<"EndMenu";
	================================================================
	Triaing Data: Positive - 10250 tweets  
		      Negative - 10048 tweets
		      
	Test Data: 500 tweets per hour, collected for 24 hours(May 16th)
	================================================================

	OPTIONS:
	  1 = Find most frequent word used to express positive feelings
	  2 = Find most frequent word used to express negative feelings
	  3 = view all the emotion score grouped by hour
	  4 = Check if a special lexicon affected people's emotion
	  5 = Quit

	================================================================

EndMenu

	print "Enter Option: ";

	my $option = <STDIN>;
	chomp $option;

	exit 0 if $option == 5;
	if ( $option == 1 ) {
		print
		  "the most frequent word people used to express positive feelings:\n";
		foreach my $key (
			sort { $pos_word_hash{$b} <=> $pos_word_hash{$a} }
			keys %pos_word_hash
		  )
		{
			print $key, "=>", $pos_word_hash{$key}, "\n";
		}
	}
	elsif ( $option == 2 ) {
		print
		  "the most frequent word people used to express negative feelings:\n";
		foreach my $key (
			sort { $neg_word_hash{$b} <=> $neg_word_hash{$a} }
			keys %neg_word_hash
		  )
		{
			print $key, "=>", $neg_word_hash{$key}, "\n";
		}
	}
	elsif ( $option == 3 ) {
		&scoreByHour;
	}
	elsif ( $option == 4 ) {
		print "Enter the word:\n";
		my $sword = <STDIN>;
		chomp $sword;
		&specialWord($sword);
	}
}

sub scoreByHour {
	my $tmp_hour = 0;
	for ( $i = 0 ; $i < 24 ; $i++ ) {
		$tmp_hour = $i + 1;
		my $pos_percent   = $pos_count[$i] / $doc_count[$i];
		my $neual_percent = $neual_count[$i] / $doc_count[$i];
		my $neg_percent   = $neg_count[$i] / $doc_count[$i];

		#print $pos_percent;
		my ($pos_short) = ( $pos_percent =~ /^([0-9]+\.\d{0,8})/ );

		#print "--$pos_short";
		my ($neual_short) = ( $neual_percent =~ /^([0-9]+\.\d{0,8})/ );
		my ($neg_short)   = ( $neg_percent   =~ /^([0-9]+\.\d{0,8})/ );
		$pos_short   *= 100;
		$neual_short *= 100;
		$neg_short   *= 100;

		print "Time $i:00-$tmp_hour:00\n";
		print "Total Positive Score(how happy people are):$comp[$i][0]\n";
		print "Total Negative Score(how unhappy people are):$comp[$i][1]\n";
		print "How many people are happy:$pos_count[$i]\t$pos_short%\n";
		print "How many people are clam:$neual_count[$i]\t$neual_short%\n";
		print "How many people are unhappy:$neg_count[$i]\t$neg_short%\n";
		print "------------------------------------------------------------\n";
	}

}

sub specialWord {
	my $sword             = shift;
	my @pos_sword_score   = ();
	my @neg_sword_score   = ();
	my @pos_sword_count   = ();
	my @neual_sword_count = ();
	my @neg_sword_count   = ();
	my $found_flag        = 0;
	chomp $sword;
	$old_time = 0;

	my $test_twi1 = "TrimedTwiData\.txt";
	my $test_twi_fh1 = new FileHandle $test_twi1 , "r"
	  or croak "Failed $test_twi1";

	while ( defined( $line = <$test_twi_fh1> ) ) {
		chomp $line;
		if ( $line =~ /^T\.([0-9]+)/ ) {
			$time = $1;
			if ( $time ne $old_time ) {
				$doc_num                  = -1;
				$found_flag               = 0;
				$pos_sword_score[$time]   = 0;
				$neg_sword_score[$time]   = 0;
				$pos_sword_count[$time]   = 0;
				$neual_sword_count[$time] = 0;
				$neg_sword_count[$time]   = 0;
			}
			$doc_num++;
			$doc_count[$time] = $doc_num;
			$old_time = $time;
			next;
		}
		if ( $line eq $sword ) {
			if ( $found_flag == 0 ) {
				if ( $twi_score[$time][$doc_num] > 0 ) {
					$pos_sword_count[$time]++;
					$pos_sword_score[$time] += $twi_score[$time][$doc_num];
				}
				elsif ( $twi_score[$time][$doc_num] < 0 ) {
					$neg_sword_count[$time]++;
					$neg_sword_score[$time] += $twi_score[$time][$doc_num];
				}
				elsif ( $twi_score[$time][$doc_num] == 0 ) {
					$neual_sword_count[$time]++;
				}
			}
		}
	}
	for ( $i = 0 ; $i < 24 ; $i++ ) {
		my $tmp_hour = $i + 1;
		print "Time $i:00-$tmp_hour:00\n";
		print "how does \"$sword\" make people happy:$pos_sword_score[$i]\n";
		print "how does \"$sword\" make people unhappy:$neg_sword_score[$i]\n";
		print
"How many people are happy because of \"$sword\":$pos_sword_count[$i]\n";
		print
"How many people stay clam because of \"$sword\":$neual_sword_count[$i]\n";
		print
"How many people are unhappy because of \"$sword\":$neg_sword_count[$i]\n";
		print "------------------------------------------------------------\n";
	}

}
