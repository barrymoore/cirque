#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "
<<<<<<< HEAD

Synopsis:

text_tool --join_rows data.txt
cat data.txt | text_tool --join_rows

Description:

Do stuff to text files.  This script is a Swiss Army Knife of
functions for manipulating text files.

Options:

  --join_rows, -j <,>

    Join all of the rows in a file using the supplied separator.

  --transpose, -t

    Not yet implimented. Transpose rows and columns. First column becomes first row etc. If
    data is not symmetrical then NULL values will be added as needed.

  --shuffle, -s

    Not yet implimented. 

  --pick, -p

    Not yet implimented. 

  --trim_rows

    Not yet implimented. 

  --trim_trailing_rows

    Not yet implimented. 

  --collapse_empty_colums

    Not yet implimented. 

  --trim_trailing_columns

    Not yet implimented. 

  --add_null_value

    Not yet implimented. 

  --reverse_rows

    Not yet implimented. 

  --reverse_columns

    Not yet implimented. 

  --header

    Not yet implimented. 

  --body

    Not yet implimented. 

  --columns

    Not yet implimented. 

  --reorder_columns

    Not yet implimented. 

  --sort

    Not yet implimented. 

";


my ($help, $join_rows);
my $opt_success = GetOptions('help'          => \$help,
			     'join_rows|j=s' => \$join_rows,
			     );

die $usage if $help || ! $opt_success;

my $file = shift;

die $usage unless $file || (! -t STDIN);

if ($join_rows) {
    join_rows($file, $join_rows);
}
else {
    my $command_line = join ' ', $0, @ARGV;
    die "FATAL : no_valid_function_called : $command_line\n";
}

exit 0;

#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------

sub join_rows {

    my ($file, $join_rows) = @_;

    my $fh = get_fh($file);
    
    my @rows = (<$fh>);
    chomp @rows;
    print join $join_rows, @rows;
    print "\n";
}


#-----------------------------------------------------------------------------

sub get_fh {

    my $file = shift;

    my $IN;
    if (! -t STDIN) {
	open ($IN, "<&=STDIN") or die "FATAL : cant_open_stdin : $!\n";
    }
    else {
	open ($IN, '<', $file) or die "FATAL : cant_open_file_for_reading : $file\n";
    }
    return $IN;
}

=======
Synopsis:

text_tool view file.txt
cat file.txt | text_tool view

Description:

Do things with column delimited text files.

Commands:

view      : View text files applying various filters and formats.
transpose : Transpose the rows and columns of a text file.
map       : Map column values to a new value.
count     : Count rows, columns and categorical values.
shuffle   : Randomize the rows or columns of a text file.
merge     : Merge data from two (or more) text files.
stats     : Calculate some basic stats on data from text files.
sort      : Sort the contents of text files in various ways.
graph     : Graph some basic data types in text files.

";

my $common_options = "
  --help, -h

  --input, -i <file_in.txt>


  --output, -o <file_out.txt>


  --header_pattern, -p ['^\#']


  --header_count, -c [0]


  --delimiter, -d [',']


  --format, -f [tab]


  --no_header, -n


  --alt_header, -a


";

my $useage .= "Common Options:\n\n$common_options\n\n";

my $COMMAND = shift(@ARGV) || '';
my $TEXT_FILE = pop @ARGV;

die "$usage\nFATAL : missing_input_file : Input file required\n\n"
  unless defined $TEXT_FILE;

if ($COMMAND eq 'view') {
  view_file($TEXT_FILE);
}
elsif ($COMMAND eq 'transpose') {
  transpose_file($TEXT_FILE);
}
elsif ($COMMAND eq 'map') {
  map_file($TEXT_FILE);
}
elsif ($COMMAND eq 'count') {
  count_file($TEXT_FILE);
}
elsif ($COMMAND eq 'shuffle') {
  shuffle_file($TEXT_FILE);
}
elsif ($COMMAND eq 'merge') {
  merge_file($TEXT_FILE);
}
elsif ($COMMAND eq 'stats') {
  stats_file($TEXT_FILE);
}
elsif ($COMMAND eq 'sort') {
  sort_file($TEXT_FILE);
}
elsif ($COMMAND eq 'graph') {
  graph_file($TEXT_FILE);
}
elsif (! defined $COMMAND) {
  die "$usage\nFATAL : invalid_command : No command given\n\n";
}
else {
  die "$usage\nFATAL : invalid_command : $COMMAND\n\n";
}

exit 0;

#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# view      : View text files applying various filters and formats.
#-----------------------------------------------------------------------------

sub view_file {

  my $usage = "
Synopsis:

text_tool view file.txt
cat file.txt | text_tool view

Description:

View column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------
# transpose : Transpose the rows and columns of a text file.
#-----------------------------------------------------------------------------

sub transpose_file {

  die "FATAL : command_not_yet_implimented : transpose\n";

  my $usage = "
Synopsis:

text_tool transpose file.txt
cat file.txt | text_tool transpose

Description:

Transpose column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------
# map       : Map column values to a new value.
#-----------------------------------------------------------------------------

sub map_file {

  die "FATAL : command_not_yet_implimented : map\n";

  my $usage = "
Synopsis:

text_tool map file.txt
cat file.txt | text_tool map

Description:

Map column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------
# count     : Count rows, columns and categorical values.
#-----------------------------------------------------------------------------

sub count_file {

  die "FATAL : command_not_yet_implimented : count\n";

  my $usage = "
Synopsis:

text_tool count file.txt
cat file.txt | text_tool count

Description:

Count column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------

sub count_columns {

  my $file = shift;

  my $IN;
  if (! -t STDIN) {
    open ($IN, "<&=STDIN") or die "Can't open STDIN\n";
  }
  else {
    open ($IN, '<', $file) or die "Can't open $file for reading:\n$!\n";
  }

 LINE:
  while (my $line = <$IN>) {
    chomp $line;
    my @columns = split /\t/, $line;
    my $count = 0;
    for my $column (@columns) {
      print join "\t", ($count++, $column);
      print "\n";
    }
    last LINE;
  }
}

#-----------------------------------------------------------------------------
# shuffle   : Randomize the rows or columns of a text file.
#-----------------------------------------------------------------------------

sub shuffle_file {

  die "FATAL : command_not_yet_implimented : shuffle\n";

  my $usage = "
Synopsis:

text_tool shuffle file.txt
cat file.txt | text_tool shuffle

Description:

Shuffle column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------
# merge     : Merge data from two (or more) text files.
#-----------------------------------------------------------------------------

sub merge_file {

  die "FATAL : command_not_yet_implimented : merge\n";

  my $usage = "
Synopsis:

text_tool merge file.txt
cat file.txt | text_tool merge

Description:

Merge column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------
# stats     : Calculate some basic stats on data from text files.
#-----------------------------------------------------------------------------

sub stats_file {

  die "FATAL : command_not_yet_implimented : stats\n";

  my $usage = "
Synopsis:

text_tool stats file.txt
cat file.txt | text_tool stats

Description:

Stats column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------
# sort      : Sort the contents of text files in various ways.
#-----------------------------------------------------------------------------

sub sort_file {

  die "FATAL : command_not_yet_implimented : sort\n";

  my $usage = "
Synopsis:

text_tool sort file.txt
cat file.txt | text_tool sort

Description:

Sort column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------
# graph     : Graph some basic data types in text files.
#-----------------------------------------------------------------------------

sub graph_file {

  die "FATAL : command_not_yet_implimented : graph\n";

  my $usage = "
Synopsis:

text_tool graph file.txt
cat file.txt | text_tool graph

Description:

Graph column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------
# stub     : Do something useful to text files.
#-----------------------------------------------------------------------------

sub stub_file {

  die "FATAL : command_not_yet_implimented : stub\n";

  my $usage = "
Synopsis:

text_tool stub file.txt
cat file.txt | text_tool stub

Description:

Stub column delimited data with various filters and formatting
applied.

Options:

$common_options

  --columns

  --filter

  --format

";

  my ($help, $input, $output, $header_pattern, $header_count, $delimiter,
      $format, $no_header, $alt_header);

  my %opt;

  my $opt_success = GetOptions(\%opt,
			       'help|h',
			       'input|i',
			       'output|o',
			       'header_pattern|p',
			       'header_count|c',
			       'delimiter|d',
			       'format|f',
			       'no_header|n',
			       'alt_header|a',
			      );

  die $usage if $opt{help} || ! $opt_success;

  my $parser = get_parser(\%opt);

  while (my $row = $parser->()) {
    print join "\t", @{$row};
    print "\n";
  }
}

#-----------------------------------------------------------------------------

sub get_parser {

  my ($opt, $data) = @_;

  my $IN;
  if (! -t STDIN) {
    open ($IN, "<&=STDIN") or die "Can't open STDIN\n";
  }
  else {
    open ($IN, '<', $TEXT_FILE) or die "FATAL : cant_open_file_for_reading : $TEXT_FILE\n$!\n";
  }

  my $parser = sub {

    # Use $opt here to configure parser

    # Use $data here to return side effect data from parser (i.e. headers)

    my $line = <$IN>;
    return $line unless defined $line;

    my @data = split /\t/, $line;
    chomp @data;
    return wantarray ? @data : \@data;
  };
    return $parser;
}
>>>>>>> 0efe59c5db26e46c7ca4d1d472e54c5f5dd8fc4f
