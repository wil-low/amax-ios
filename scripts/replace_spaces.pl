use strict;
use warnings;
use Encode;

open (INF, "<:raw", $ARGV[0]) or die "$!: $ARGV[0]";
my $text = do { local $/; <INF> };
close (INF);

# now decode to use character semantics (no need to specify LE or BE when reading)
my $content = decode('UTF-16LE', $text); 
my @lines = split /\n/, $content;

my @processed;
# some code that turns @lines into @processed goes here
foreach my $line (@lines) {
	my @values = split (/\s*=/, $line);
	if (scalar(@values) == 2) {
		$values[0] =~ /"(.+?)"/;
		my $str = $1;
		$str =~ s/ /_/g;
		$line = "\"$str\" =$values[1]";
	}		
	push (@processed, $line);
}

# write file
my $output_str = join "\n", @processed;

open (OUTF, '>:raw', $ARGV[1]);
print (OUTF encode("UTF-16LE", $output_str));
close (OUTF);

