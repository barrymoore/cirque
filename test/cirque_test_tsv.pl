#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

use lib "$ENV{HOME}/artemisia/lib/";
use Cirque::TSV;
use Cirque::Tables qw(:all);

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

cirque_test_tsv.pl data/tsv_data.txt

Description:

Test script for developing Cirque::TSV.pm

";


my ($help);
my $opt_success = GetOptions('help'    => \$help,
			      );

die $usage if $help || ! $opt_success;

my $file = shift;
die $usage unless $file;

my $tsv = Cirque::TSV->new(file => $file);

my @data;
while (my $record = $tsv->next_record) {

  push @data, [@{$record}{qw(name sex hobby)}];
  # print join "\t", @{$record}{qw(name sex hobby)};
  # print "\n";
}

print html_table(\@data, [qw(name sex hobby)], {full_page => 1});
