#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

cat list.txt | list2comma.pl
list2comma.pl list.txt # One record per line in text file.
list2comma.pl list.tsv # Use first column in TSV
cut -f 2 list.tsv | list2comma.pl # Use second column of TSV

Description:

Convert a stream of text records into a comma separated list.  If the
text records are from a tab delimited file, the first column is used.

";

my ($help);
my $opt_success = GetOptions('help'    => \$help,
			      );

die $usage if ! $opt_success;
print $usage if $help;

my $file = shift @ARGV;

my $IN;
if (! -t STDIN) {
    open ($IN, "<&=STDIN") or die "Can't open STDIN\n";
}
else {
    open ($IN, '<', $file) or die "Can't open $file for reading:\n$!\n";
}

my @list;
LINE:
while (my $line = <$IN>) {
    chomp $line;
    my @cols = split /\t/, $line;
    push @list, $cols[0];
}

print join ',', @list;
print'';

