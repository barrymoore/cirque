#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Text::CSV;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

csv2tsv.pl file.csv > file.tsv

Description:

Convert a CSV file (complete with commas embeded in fields)
into a TSV file.

";


my ($help);
my $opt_success = GetOptions('help'    => \$help,
			      );

die $usage if ! $opt_success;
print $usage if $help;

my $file = shift;
die $usage unless $file;
open (my $IN, '<', $file) or die "FATAL : cant_open_file_for_reading : /home/ubuntu/cirque/scripts/csv2tsv.pl\n$!\n";


my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1 });
while (my $row = $csv->getline ($IN)) {
    print join "\t", @{$row};
    print "\n";
}
close $IN;

