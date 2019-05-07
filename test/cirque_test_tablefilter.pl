#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

use lib "$ENV{HOME}/cirque/lib/";
use Cirque::TSV;
use Cirque::TableFilter;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

cirque_test_tablefilter.pl data/tsv_data.txt

Description:

Test script for developing Cirque::TableFilter.pm

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

  my @row;
  for my $col (qw(name sex hobby)) {
    my $color = ($col eq 'name'  ? 'red'   :
		 $col eq 'sex'   ? 'green' :
		 $col eq 'hobby' ? 'blue'  :
		 'white');
    push @row, [$record->{$col}, {bgcolor => $color}];
  }
  push @data, \@row;
  # print "\n";
}

my $table = Cirque::TableFilter->new(data           => \@data,
				     columns        => [qw(name sex hobby)],
				     full_page      => 1,
				     alternate_rows => 1);

my $table_txt = $table->build_table();

print "$table_txt\n";
print '';
