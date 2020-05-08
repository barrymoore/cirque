#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use Statistics::Descriptive;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------

my $usage = "

This script will take one or more datafiles (use - as the file name for input
from STDIN) and output a list of descriptive statistics about a give column of 
data.  The options described below allow some control of the input and output.

statistics_descrpt [options] datafile1 [datafile2 datafile3...]

Options:

    --col n

      Which column of the input data should we use?

    --find filename

      Use the linux find command to find the given file name under the current
      working directory and add these files to those given on the command line.

    --header n

      Skip n lines at the top of the input.

    --footer n

      Skip n lines at the end of the input.

";

my ($col, $find, $header, $footer);

my $opt_results = GetOptions('col=i'    => \$col,
			     'find=s'   => \$find,
			     'header=i' => \$header,
			     'footer=i' => \$footer,
			     );

$col--;
my @files = @ARGV;
push @files, '-' if (@files < 1 && ! $find);
my @find_files = `find ./ -name $find` if $find;
push @files, @find_files;
chomp @files;


die $usage unless $opt_results && @files;

my $data = parse_data(@files);
my $stats = get_stats($data, @files);
print_stats($stats);

exit(0);

#-----------------------------------------------------------------------------
#----------------------------------- SUBS ------------------------------------
#-----------------------------------------------------------------------------
sub parse_data {
    my @files = @_;
    my %data;
    
    my $file_order = 0;
    my $line_count;
    for my $file (sort @files) {
	my $IN;
	if (! -t STDIN) { 
	    open ($IN, "<&=STDIN") or die "Can't open STDIN\n";
	}
	else {
	    open ($IN, $file) or die "Can't open $file for reading: $!\n";
	    $data{$file}{order} = $file_order++;
	}
	while (<$IN>) {
	    $line_count++;
	    next if $header && $line_count <= $header;
	    my @line_data = split;
	    my $datum;
	    if ($col) {
		$datum = $line_data[$col];
	    }
	    else {
		$datum = pop @line_data;
	    }
	    next unless $datum =~ /-?\d*\.?\d+/;
	    push @{$data{$file}{data}}, $datum;
	}
	if ($footer) {
	    splice (@{$data{$file}{data}}, $footer * -1, $footer);
	}
    }
    return \%data;
}
#-----------------------------------------------------------------------------
sub get_stats {
	my ($data, @files) = @_;

	my %stat_hash;
	for my $file (keys %$data) {
		my $stat = Statistics::Descriptive::Full->new();
		$stat->add_data(@{$$data{$file}{data}}); 
		$stat_hash{$file}{order}      = $$data{$file}{order};
		$stat_hash{$file}{mean}       = $stat->mean();
		$stat_hash{$file}{trm_mean}   = $stat->trimmed_mean(0.1, 0.1);
		$stat_hash{$file}{min}        = $stat->min();
		$stat_hash{$file}{q1}         = $stat->quantile(1);
		$stat_hash{$file}{median}     = $stat->median();
		$stat_hash{$file}{q3}         = $stat->quantile(3);
		$stat_hash{$file}{max}        = $stat->max();
		$stat_hash{$file}{iqr}        = ($stat_hash{$file}{q3} -
						 $stat_hash{$file}{q1});
		$stat_hash{$file}{mode}       = $stat->mode();
		$stat_hash{$file}{variance}   = $stat->variance();
		$stat_hash{$file}{std_dev}    = $stat->standard_deviation();
		$stat_hash{$file}{count}      = $stat->count();
		$stat_hash{$file}{sum}        = $stat->sum();
	}
	return \%stat_hash;
}
#-----------------------------------------------------------------------------
sub print_stats {
	my $stats = shift;

	print "Stats\t";
	print join ("\t", sort {$$stats{$a}{order} <=> $$stats{$b}{order}} 
		    keys %$stats);
	print "\n";

	my @stat_types = qw(mean trm_mean min q1 median q3 max iqr mode std_dev variance 
			    count sum);

	for my $stat_type (@stat_types) {
		print "$stat_type\t";
		for my $file (sort {$$stats{$a}{order} <=> $$stats{$b}{order}}
			      keys %$stats) {
			print defined ($$stats{$file}{$stat_type}) ?
			    $$stats{$file}{$stat_type} . "\t" :
			    "N/A\t";
		}
		print "\n";
	}
}
