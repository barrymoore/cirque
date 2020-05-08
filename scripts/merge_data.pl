#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

merge_data  --col1 1 --col2 0 data1.txt data2.txt

# Merge GFF3 files on feature coordinates
merge_data  --col1 0,3,4 --col2 0,3,4 data1.gff3 data2.gff3

# As above by print only the attributes of the second GFF3 file
merge_data  --col1 0,3,4 --col2 0,3,4 --pcol2 8 data1.gff3 data2.gff3

Description:

Merge together the data from two files based on a shared ID columns;

Options:

  --col1

    The ID column(s) in the 1st data file (use comma separated list
    for multiple column keys).

  --col2

    The ID column in the 2nd data file (use comma separated list for
    multiple column keys).

  --split, -s

    The charachter to split columns on.

  --pcol1

    The columns to print from file 1 (defaults to all).

  --pcol2

    The columns to print from file 2 (defaults to all).

  --uniq, -u

    Ensure that output lines are unique.

  --right_outer_join

    Print every line in file 2 regardless of an ID match in file 1.

  --compare, -c 0,2,5:1,2,7

    Only print the line if the columns to compare are NOT equal.
    Columns to compare are given as two comma separated lists with the
    two lists separated by a colon. The lists of column(s) must each
    of equal length (i.e. if three columns are given before the colon,
    then three columns must be given after the colon) and consist of
    0-based integer indeces of columns.

";

my ($help, $col1, $col2, $split, $pcol1, $pcol2, $print_uniq,
    $right_outer_join, $compare);

my $opt_success = GetOptions('help'      	=> \$help,
			     'col1=s'    	=> \$col1,
			     'col2=s'    	=> \$col2,
			     'split|s=s' 	=> \$split,
			     'pcol1=s'   	=> \$pcol1,
			     'pcol2=s'   	=> \$pcol2,
			     'uniq|u'    	=> \$print_uniq,
			     'right_outer_join' => \$right_outer_join,
			     'compare|c=s'      => \$compare,
			      );

die $usage if ! $opt_success;

if ($help) {
  print $usage;
  exit(0);
}

$split ||= "\t";
$split = qr|$split|;

my ($file1, $file2) = @ARGV;
die $usage unless $file1 && $file2;

$col1 ||= 0;
$col2 ||= 0;

my @cols1 = split /,/, $col1;
my @cols2 = split /,/, $col2;
my @pcols1;
@pcols1 = split /,/, $pcol1 if defined $pcol1;
my @pcols2;
@pcols2 = split /,/, $pcol2 if defined $pcol2;

my (@compare1, @compare2);

if ($compare) {
  my ($compare1_txt, $compare2_txt) = split /:/, $compare;
  @compare1 = split /,/, $compare1_txt;
  @compare2 = split /,/, $compare2_txt;
  if (scalar @compare1 ne scalar @compare1) {
    print STDERR "FATAL : unequal_compare_lists : $compare\n";
    die $usage;
  }
}

my ($index, $column1_count) = parse_file(\@cols1, $file1);

open (my $IN, '<', $file2) or die "Can't open $file2 for reading\n$!\n";

my %uniq;
LINE:
while (<$IN>) {

	chomp;
	my @columns2 = split /$split/, $_;
	my $key = join ':', @columns2[@cols2];
	if (! $right_outer_join) {
	  next LINE unless $index->{$key};
	}
	my @print_columns2 = @pcols2 ? @columns2[@pcols2] : @columns2;
	my $column1_set = $index->{$key};
	if (! $column1_set) {
	  my @tmp;
	  my $column1_idx = @pcols1 ? $#pcols1 : $column1_count - 1;
	  map {push @tmp, '.'} (0 ..  $column1_idx);
	  $column1_set = [\@tmp];
	}

      SET:
	for my $columns1 (@{$column1_set}) {

	  if ($compare) {
	    my $txt1 = join ':', @{$columns1}[@compare1];
	    my $txt2 = join ':', @columns2[@compare2];
	    next LINE if $txt1 eq $txt2;
	  }

	  my @print_columns1 = @pcols1 ? @{$columns1}[@pcols1] : @{$columns1};
	  my @output_values = (@print_columns1, @print_columns2);
	  map {$_ = '' unless defined $_} @output_values;
	  my $output = join "\t", @output_values;
	  next SET if $print_uniq && $uniq{$output}++;
	  print "$output\n";
	  print '';
	}
	print '';
}

exit(0);

#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------

sub parse_file {

	my ($cols1, $file1) = @_;

	open (my $IN, '<', $file1) or die "Can't open $file1 for reading\n$!\n";

	my $column1_count;
	my %index_hash;
	while (<$IN>) {
		chomp;
		my @columns1 = split /$split/, $_;
		my $key = join ':', @columns1[@{$cols1}];
		push @{$index_hash{$key}}, \@columns1;
		$column1_count = scalar @columns1;
	}
	return \%index_hash, $column1_count;
}
