#!/usr/bin/perl
use strict;
use warnings;

our %eventType=qw(EV_VOC 0 EV_SIGN_ENTER 1 EV_ASP_EXACT 2 EV_RISE 3 EV_DEGREE_PASS 4
EV_VIA_COMBUSTA 5 EV_RETROGRADE 6 EV_ECLIPSE 7 EV_TITHI 8 EV_NAKSHATRA 9 EV_SET 10
EV_DECL_EXACT 11 EV_NAVROZ 12 EV_TOP_DAY 13 EV_PLANET_HOUR 14 EV_STATUS 15 EV_SUN_RISE 16
EV_MOON_RISE 17 EV_MOON_MOVE 18 EV_SEL_DEGREES 19 EV_DAY_HOURS 20 EV_NIGHT_HOURS 21
EV_SUN_DAY 22 EV_MOON_DAY 23 EV_TOP_MONTH 24 EV_MOON_PHASE 25 EV_ZODIAC_SIGN 26
EV_PANEL 27 EV_TOPIC_BUTTON 28 EV_DEG_2ND 29 EV_WEEK_GRID 30 EV_MONTH_GRID 31
EV_DECUMBITURE 32 EV_DECUMB_ASPECT 33 EV_DECUMB_BEGIN 34 EV_SUN_DEGREE_LARGE 35
EV_MOON_SIGN_LARGE 36 EV_HELP 37 EV_ASP_EXACT_MOON 38 EV_DEGPASS0 39 EV_DEGPASS1 40
EV_DEGPASS2 41 EV_DEGPASS3 42 EV_HELP0 43 EV_HELP1 44 EV_ASTRORISE 45 EV_ASTROSET 46
EV_APHETICS 47 EV_FAST 48 EV_ASCAPHETICS 49 EV_MSG 50 EV_BACK 51 EV_TATTVAS 52
EV_LAST 53
);

my $lang = $ARGV[0];

my @interpret_files = glob("../interpret/$lang/*.txt");

my %event_type_hash;

foreach my $infile (@interpret_files) {
	open (INF, "<$infile") or die "$!: $infile";
	my @buf = <INF>;
	close (INF);
	$buf[0] =~ /\!\!type\s*(\w+)/i;
	my $evt=$1;
	if ($evt eq 'EV_MSG' or $evt =~ /EV_DEGPASS\d+/) {
		next;
	}
	my $event_type = $eventType{$evt};
	if ($event_type !~ /^\d+$/) {
		die "Event $evt not defined in $infile! Skipped";
		next;
	}
	$buf[2]=~/\!\!planet\s*(.+?)[\n\r]+/i;
	my $planet=$1;
	my $out = '';
	my $count = 0;
	warn "$infile\n";
	foreach my $line (@buf) {
		$line =~ s/\/\/.+//is;
		next if $line !~ /%[\d\s\,\-]+%/;
		$line =~ s/\s*\Z//is;
		#$line =~ s/\.+\Z//is if $evt ne 'EV_MSG';
		$line =~ s/.*?%(.*?)%\s*//is;
		my @param = split (/,/, $1);
		for (my $i = 0; $i < 3; ++$i) {
			if (!defined ($param[$i])) {
				$param[$i] = -1;
			}
			else {
				$param[$i] = int($param[$i]);
			}
		}
		if ($evt =~ /EV_HELP/) {
			$line =~ s/^(.+?)\|/<h1>$1<\/h1><p>/;
		}
		else {
			$line =~ s/[\*\~\#\^\$\}\>\@\=\{]//g;
		}

		$line =~ s/\|/<\/p><p>/g;
		$line =~ s/<p>--<\/p>/<hr\/>/g;
		$line =~ s/--/&#8212;/g;
		
		my $len = 0;
		do{
			use bytes; $len=length($line);
		};

#		$out .= pack('cnNc', 1, 2, 3, 0xff); # 
		$out .= pack('cnnnna*', $planet, $param[0], $param[1], $param[2], $len, $line);
		++$count;
	}
	my $len = 0;
	do{
		use bytes; $len=length($out);
	};
	$event_type_hash{$event_type} = [$out, $len, $count]; # data, length, event count
}

my $key_count = scalar(keys (%event_type_hash));
my $out = 'S&WA' . pack('n', $key_count);
my $abs_data_offset = 6 + $key_count * 7;
my @sorted_keys = sort {$a <=> $b} keys (%event_type_hash);
foreach (@sorted_keys) {
	$out .= pack ('cNn', $_, $abs_data_offset, $event_type_hash{$_}->[2]);
	$abs_data_offset += $event_type_hash{$_}->[1];
}
foreach (@sorted_keys) {
	$out .= $event_type_hash{$_}->[0];
}
print $out;

