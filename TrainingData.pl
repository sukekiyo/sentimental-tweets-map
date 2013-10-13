#!/usr/local/bin/perl -w

#
# This program get tweets from search.twitter.com and
# with labels indicating their attitudes (positive/negative)
# we use those tweets as our original training data

use strict;

use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;
use Time::HiRes;

my $ROBOT_NAME = 'KlossBot/1.0';
my $ROBOT_MAIL = 'xwang@jhu.edu';
my $count      = 1;

my $ua = new LWP::UserAgent;    # create an new LWP::UserAgent
$ua->agent($ROBOT_NAME);        # identify who we are
$ua->from($ROBOT_MAIL);         # and give an email address in case anyone would
                                # like to complain

#my $url = $ARGV[0];
my $positive_url =
"http://search.twitter.com/search?ands=&from=&lang=en&near=&nots=&ors=&phrase=&q=&ref=&refresh=true&rpp=50&since=&tag=&to=&tude%5B%5D=%3A%29&units=mi&until=&within=15&since_id=71003058515091460";
my $negative_url =
"http://search.twitter.com/search?ands=&from=&lang=en&near=&nots=&ors=&phrase=&q=&ref=&refresh=true&rpp=50&since=&tag=&to=&tude%5B%5D=%3A%28&units=mi&until=&within=15&since_id=71003531070537730";

print <<"EndOfMenu";
                
	============================================================
	Get Training Data: 1 = Positive   2 = Negative   3 = Quit

	============================================================

EndOfMenu

print "Enter Option: ";

my $option = <STDIN>;
chomp $option;

exit 0 if $option == 3;

while (1) {
	&get_response($option);
	sleep(30);
}

sub get_response {
	my $label = shift;
	my $request;
	if ( $label == 1 ) {
		$request = new HTTP::Request 'GET' => $positive_url;
		open( DATA, ">>TrainPos.txt" ) || die("Could not open file");
		DATA->autoflush(1);
	}
	elsif ( $label == 2 ) {
		$request = new HTTP::Request 'GET' => $negative_url;
		open( DATA, ">>TrainNeg.txt" ) || die("Could not open file");
		DATA->autoflush(1);
	}
	else {
		print "label error";
	}
	my $response = $ua->request($request);

	my $flow = $response->content;
	my $twi  = "";
	my $flag = 1;

	while ( $flag eq 1 ) {
		if ( $flow =~ s/"text":"(.+?)","id":[0-9]+// ) {
			$twi = $1;
			print DATA "$twi\t|";

			if ( $label == 1 ) {
				print DATA "POS\n";
			}
			elsif ( $label == 2 ) {
				print DATA "NEG\n";
			}
			else {
				print "subfunc label error";
			}

			#print DATA "==========================$count\n";
			$count++;
			$flag = 1;
		}
		else {
			$flag = 0;    #cannot match so stop the loop
		}
	}
}
