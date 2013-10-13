#!/usr/local/bin/perl -w

#
# This program get tweets from search.twitter.com and
# label them with number presenting the time those tweets are published
# we only take tweets written from JHU within a radius of five miles

use strict;

use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;
use Time::HiRes;

open( DATA, ">TwiData.txt" ) || die("Could not open log file");
DATA->autoflush(1);

my $ROBOT_NAME = 'KlossBot/1.0';
my $ROBOT_MAIL = 'xwang@jhu.edu';
my $count      = 1;

my $ua = new LWP::UserAgent;    # create an new LWP::UserAgent
$ua->agent($ROBOT_NAME);        # identify who we are
$ua->from($ROBOT_MAIL);         # and give an email address in case anyone would
                                # like to complain

#my $url = $ARGV[0];
my $url =
"http://search.twitter.com/search?ands=&from=&geocode=39.328679%2C-76.621653%2C5.0mi&lang=en&near=johns+hopkins+university&nots=&ors=&phrase=&q=&ref=&refresh=true&result_type=recent&rpp=50&since=&tag=&to=&units=mi&until=&within=5&since_id=69785077881643010";
while (1) {
	&get_response;
	sleep(360);
}
close DATA;
exit(0);

sub get_response {
	my $request = new HTTP::Request 'GET' => $url;
	my $response = $ua->request($request);

	my $flow = $response->content;
	my $twi  = "";
	my $flag = 1;

	(
		my $sec,  my $min,  my $hour, my $mday, my $mon,
		my $year, my $wday, my $yday, my $isdst
	) = localtime();

	while ( $flag eq 1 ) {
		if ( $flow =~ s/"text":"(.+?)","id":[0-9]+// ) {
			$twi = $1;
			print DATA "$twi\t|";
			( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
			  localtime();
			print DATA "$hour\n";

			#print DATA "==========================$count\n";
			$count++;
			$flag = 1;
		}
		else {
			$flag = 0;    #cannot match so stop the loop
		}
	}
}
