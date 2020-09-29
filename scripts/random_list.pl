#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

random_list file.txt
cat file.txt | random_list
random_list --permute 1000 --pick 11 file.txt | histogram


Description:

This script will take a text file as input and print out the file in
random order.  It uses the Fisher-Yates Shuffle to randomize the list.
With the options described below you can pick a given number of values
from the list and print just those, and you can permute the shuffle
pick sequence a given number of times.

Options:

  --permute, -m 1

    Lists are randomized by a Fisher-Yates shuffle.  The permute
    option describes how many rounds of shuffling are done.  The
    default is 1 which is sufficient for most purposes.

  --pick, -p 100

    Provide an integer value to --print and the script will print only
    that given number of values from the top of the shuffled list.
    Default is to print the entire shuffled list.

  --uniq, -u

    When used with --pick, the --uniq option ensures that the set of
    picked values is unique.  If the list being picked from is not
    unique then --pick may pick the same value multiple times (from
    different rows of the input) - this option ensures that doesn't
    happen.  With the uniq option, the samples are picked one at a
    time until the count of --pick have been chosen, so you still get
    a weighted pick if for duplicate rowes.

  --prob_emit, -e 1e-3

    Emit lines with the given probability.  For example if you supply
    a value of 1e-3 each line will have a 1/1000 chance of being
    printed and thus over a large number of lines you should print
    about 1 line for every 1000 lines.

";

my ($help, $permute, $pick, $uniq, $prob_emit);
my $opt_success = GetOptions('help'          => \$help,
			     'permute=i'     => \$permute,
			     'pick=i'        => \$pick,
			     'uniq|u'        => \$uniq,
			     'prob_emit|e=s' => \$prob_emit,
			      );

die $usage if $help || ! $opt_success;

my $file = shift;
die $usage unless $file || ! -t;

$permute ||= 1;

my $IN;
if (! -t STDIN) {
	open ($IN, "<&=STDIN") or die "Can't open STDIN\n";
}
else {
	open ($IN, '<', $file) or die "Can't open $file for reading:\n$!\n";
}

if ($prob_emit) {
    print_prob_emit($IN, $uniq, $prob_emit);
}
else {
    shuffle($IN, $permute, $uniq, $pick)
}

exit(0);

#-----------------------------------------------------------------------------
#----------------------------------- SUBS ------------------------------------
#-----------------------------------------------------------------------------

sub shuffle {

    my ($IN, $permute, $uniq, $pick) = @_;

    my @list = <$IN>;
    chomp @list;
    $pick ||= scalar @list;
    
    for (1 .. $permute) {
	#Fisher-Yates Shuffle
	my $n = scalar @list;
	while ($n > 1) {

	    my $k = int rand($n--);
	    ($list[$n], $list[$k]) = ($list[$k], $list[$n]);
	}
    }

    # Control size of pick
    my $list_size = scalar @list;
    if ($pick > $list_size) {
	warn "WARN : reducing_size_of_pick : PICK=$pick, LIST=$list_size\n";
	$pick = scalar @list;
    }

    # Unique List
    @list = uniq_list(@list) if $uniq;
    $list_size = scalar @list;

    # Control size of pick after uniq
    if ($pick > scalar @list) {
	warn "WARN : reducing_size_of_pick_after_uniq : PICK=$pick, LIST=$list_size\n";
	$pick = scalar @list;
    }

    print join "\n", @list[0 .. $pick - 1];
    print "\n";
}

#-----------------------------------------------------------------------------

sub uniq_list {

    my %hash;
    map {$hash{$_}++} @_;
    my @uniq = keys %hash;
    return wantarray ? @uniq : \@uniq;
}

#-----------------------------------------------------------------------------

sub print_prob_emit {

    my ($IN, $uniq, $prob_emit) = @_;

    $prob_emit = 1 if $prob_emit > 1;
    my $rand_max = int(1/$prob_emit);

    my %uniq;
    while (my $value = <$IN>) {
	next unless int(rand($rand_max)) == ($rand_max - 1);
	print $value unless ($uniq && exists $uniq{$value});
	$uniq{$value}++;
	print '';
    }
}

#-----------------------------------------------------------------------------
