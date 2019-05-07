package Cirque::TableFilter;

use strict;
use warnings;

use base qw(Cirque::Base);
use Cirque::Utils qw(:all);

use vars qw($VERSION);

$VERSION = 0.0.1;

=head1 NAME

L<Cirque::TableFilter> - Create complex filterable HTML tables using
the TableFilter JavaScript library.

=head1 VERSION

This document describes L<Cirque::TableFilter> version 0.0.1

=head1 SYNOPSIS

    use Cirque::TableFilter;
    my $tf = Cirque::TableFilter->new($data, $args);

    print $tf->build_table(\@table_data, {columns => \@columns});

=head1 DESCRIPTION

L<Cirque::TableFilter> provides a Perl interface to build HTML tables
with rich filtering capability provided by the L<TableFilter
JavaScript library|https://www.tablefilter.com/>

=cut

=head1 Constructor

New L<Cirque::TSV> objects are created by the class method new.
Arguments should be passed to the constructor as a list (or reference)
of key value pairs.  If the argument list has only a single argument,
then this argument is applied to the 'file' attribute and thus
specifies the TSV filename.  All attributes of the L<Cirque::TSV>
object can be set in the call to new. An simple example of object
creation would look like this:

    my $parser = Cirque::TSV->new('tsv_header.txt');

    # This is the same as above
    my $parser = Cirque::TSV->new('file' => 'tsv_header.txt');


The constructor recognizes the following parameters which will set the
appropriate attributes:

=over

=item * C<< file => tsv_header.txt >>

This optional parameter provides the filename for the file containing
the data to be parsed. While this parameter is optional either it, or
the following fh parameter must be set.

=item * C<< fh => $fh >>

This optional parameter provides a filehandle to read data from. While
this parameter is optional either it, or the previous file parameter
must be set.

=back

=cut

#-----------------------------------------------------------------------------
#-------------------------------- Constructor --------------------------------
#-----------------------------------------------------------------------------

=head2 new

Title   : new
Usage   : Cirque::TSV->new();
Function: Creates a Cirque::TSV object;
Returns : An Cirque::TSV object
Args    :

=cut

sub new {
  my ($class, @args) = @_;
  my $self = $class->SUPER::new(@args);
  return $self;
}

#-----------------------------------------------------------------------------
#----------------------------- Private Functions -----------------------------
#-----------------------------------------------------------------------------

=head1 Private Functions

=cut

sub _initialize_args {
  my ($self, @args) = @_;

  ######################################################################
  # This block of code handels class attributes.  Use the
  # @valid_attributes below to define the valid attributes for
  # this class.  You must have identically named get/set methods
  # for each attribute.  Leave the rest of this block alone!
  ######################################################################
  my $args = $self->SUPER::_initialize_args(@args);
  # Set valid class attributes here
  my @valid_attributes = qw(data columns full_page alternate_rows);
  $self->set_attributes($args, @valid_attributes);
  ######################################################################
}

# =head2 _private_function
#
#  Title   : _private_function
#  Usage   : $args = _private_function(@_);
#  Function: Take a list of key value pairs that may be structured as an
#	   array, a hash or and array or hash reference and return
#	   them as a hash or hash reference depending on calling
#	   context.
#  Returns : Hash or hash reference.
#  Args    : An array, hash or reference to either.
#
# =cut
#
# sub _private_function {
#
#	my ($args) = @_;
#
#	return '_Hello_Private_World';
# }

#-----------------------------------------------------------------------------
#-------------------------------- Attributes ---------------------------------
#-----------------------------------------------------------------------------

=head1 Attributes

=head2 data

 Title   : data
 Usage   : $data = $self->data([['Fred', 'male', '32'],['Wilma', 'female', 27]]);

 Function: Get/set the data for the table.  Data is in the form of a datastructure.  See Args below
 Returns : The data structure for the table data - see format in Args below.
 Args    : A data structure for the table data.
	   An arrayref (one element for each row) of arrayrefs (one element for each column) or a
	   hashrefs (one key/value pair for each column).  For example:
	   my $array_data = [[1,2,3],[4,5,6]];
	   my $hash_data  = [{col1 => 1, col2 => 2, col3 => 3},
			     {col1 => 4, col2 => 5, col3 => 6}];

=cut

sub data {
  my ($self, $data) = @_;

  if ($data) {

    # Validate data value
    throw_msg('array_reference_required', 'Argument to Cirque::' .
	      'TableFilter::data must be a reference to an array')
      unless ref $data eq 'ARRAY';

    $self->{data} = $data;
  }

  return wantarray ? @{$self->{data}} : $self->{data};
}

#-----------------------------------------------------------------------------

=head2 columns

 Title   : columns
 Usage   : $columns = $self->columns(qw(column1 columnB third_column));
 Function: Get/set the list of columns for that table.  This list will
	   be used for creating headers and for column ordering when the table
	   data is represented as a hash.
 Returns : An array(ref) of column names.
 Args    : An arrayref of column names.

=cut

sub columns {
  my ($self, $columns) = @_;

  if ($columns) {

    # Validate columns value
    throw_msg('array_reference_required', 'Argument to Cirque::' .
	      'TableFilter::columns must be a reference to an array')
      unless ref $columns eq 'ARRAY';

    $self->{columns} = $columns;
  }

  return wantarray ? @{$self->{columns}} : $self->{columns};
}

#-----------------------------------------------------------------------------

=head2 full_page

 Title   : full_page
 Usage   : $full_page = $self->full_page(1);
 Function: Get/set the full_page attribute
 Returns : 0 or 1 (0=turn off, 1=turn on TableFilter alternate rows)
 Args    : 0 or 1

=cut

sub full_page {
  my ($self, $full_page) = @_;

  if ($full_page) {
    $self->{full_page} = $full_page;
  }

  $self->{full_page} ||= 0;

  return wantarray ? @{$self->{full_page}} : $self->{columns};
}

#-----------------------------------------------------------------------------

=head2 alternate_rows

 Title   : alternate_rows
 Usage   : $alternate_rows = $self->alternate_rows(1);
 Function: Get/set the alternate_rows attribute
 Returns : 0 or 1 (0=turn off, 1=turn on TableFilter alternate rows)
 Args    : 0 or 1

=cut

sub alternate_rows {
  my ($self, $alternate_rows) = @_;

  if ($alternate_rows) {
    $self->{alternate_rows} = $alternate_rows;
  }

  $self->{alternate_rows} ||= 0;

  return wantarray ? @{$self->{alternate_rows}} : $self->{alternate_rows};
}

#-----------------------------------------------------------------------------

# =head2 base_path
#
#  Title   : base_path
#  Usage   : $base_path = $self->base_path('/path/to/tablefilter/');
#  Function: Get/set the base_path attribute with the path to the tablefilter
#            code base.  This should point to the directory that contains the
#            tablefilter.js file.
#  Returns : The tablefilter directory path
#  Args    : A tablefilter directory path
#
# =cut
#
# sub base_path {
#   my ($self, $base_path) = @_;
#
#   if ($base_path) {
#     throw_msg('invalid_path', "The value $base_path is not a valid directory")
#       unless -d $base_path;
#     throw_msg('mising_tablefilter_file', "The value $base_path/" .
#	      "tablefilter.js does not exist")
#       unless -e "$base_path/tablefilter.js";
#     $self->{base_path} = $base_path;
#   }
#
#   return wantarray ? @{$self->{base_path}} : $self->{columns};
# }
#
# #-----------------------------------------------------------------------------
#
#
# =head2 case_sensitive
#
#  Title   : case_sensitive
#  Usage   : $case_sensitive = $self->case_sensitive(qw(column1 columnB third_column));
#  Function: Get/set case_sensitive
#  Returns : An case_sensitive value
#  Args    : An case_sensitive value
#
# =cut
#
# sub case_sensitive {
#   my ($self, $case_sensitive) = @_;
#
#   if ($case_sensitive) {
#     $self->{case_sensitive} = $case_sensitive;
#   }
#
#   return wantarray ? @{$self->{case_sensitive}} : $self->{case_sensitive};
# }
#
#
# #-----------------------------------------------------------------------------
#
#
# =head2 col_widths
#
#  Title   : col_widths
#  Usage   : $col_widths = $self->col_widths(qw(column1 columnB third_column));
#  Function: Get/set col_widths
#  Returns : An col_widths value
#  Args    : An col_widths value
#
# =cut
#
# sub col_widths {
#   my ($self, $col_widths) = @_;
#
#   if ($col_widths) {
#     $self->{col_widths} = $col_widths;
#   }
#
#   return wantarray ? @{$self->{col_widths}} : $self->{col_widths};
# }
#
#
# #-----------------------------------------------------------------------------
#
#
# =head2 exact_match
#
#  Title   : exact_match
#  Usage   : $exact_match = $self->exact_match(qw(column1 columnB third_column));
#  Function: Get/set exact_match
#  Returns : An exact_match value
#  Args    : An exact_match value
#
# =cut
#
# sub exact_match {
#   my ($self, $exact_match) = @_;
#
#   if ($exact_match) {
#     $self->{exact_match} = $exact_match;
#   }
#
#   return wantarray ? @{$self->{exact_match}} : $self->{exact_match};
# }
#
#
# #-----------------------------------------------------------------------------
#
#
# =head2 columns_exact_match
#
#  Title   : columns_exact_match
#  Usage   : $columns_exact_match = $self->columns_exact_match(qw(column1 columnB third_column));
#  Function: Get/set columns_exact_match
#  Returns : An columns_exact_match value
#  Args    : An columns_exact_match value
#
# =cut
#
# sub columns_exact_match {
#   my ($self, $columns_exact_match) = @_;
#
#   if ($columns_exact_match) {
#     $self->{columns_exact_match} = $columns_exact_match;
#   }
#
#   return wantarray ? @{$self->{columns_exact_match}} : $self->{columns_exact_match};
# }
#
# #-----------------------------------------------------------------------------
#
#
# =head2 exclude_rows
#
#  Title   : exclude_rows
#  Usage   : $exclude_rows = $self->exclude_rows(qw(column1 columnB third_column));
#  Function: Get/set exclude_rows
#  Returns : An exclude_rows value
#  Args    : An exclude_rows value
#
# =cut
#
# sub exclude_rows {
#   my ($self, $exclude_rows) = @_;
#
#   if ($exclude_rows) {
#     $self->{exclude_rows} = $exclude_rows;
#   }
#
#   return wantarray ? @{$self->{exclude_rows}} : $self->{exclude_rows};
# }


#-----------------------------------------------------------------------------
#----------------------------------- Methods -------------------------------
#-----------------------------------------------------------------------------

=head1 Methods

=head2 tsv_table

 Title   : tsv_table
 Usage   : tsv_table(argument);
 Function: Do something
 Returns : Something
 Args    : Something else

=cut

sub tsv_table {

  throw_msg('method_not_yet_implimented', 'Cirque::TableFilter::tsv_table');
  my $argument = shift @_;

  my $value = 1;

  return $value;
}

#-----------------------------------------------------------------------------

=head2 build_table

 Title   : build_table
 Usage   : build_table($list_of_array_refs, $columns, $args);
	   build_table($list_of_hash_refs, $columns, $args);
 Function: Print an HTML table from an array or hash.
 Returns : N/A

 Args : * First argument is an array reference.  The array
	  contains array or hash refs of the table data, one for each
	  row.
	* Second argument is an array ref of column names.  This will be
	  used to create a header row (but see arguments below), and for
	  the hash ref, will determine the order of the columns.
	* Third (optional) argument is a hash ref the provides
	  additional parameters used to customize the table.

=cut

sub build_table {

  my $self = shift @_;

  my $table_text;

  # HTML page header
  if ($self->full_page) {
    #$table_text = html_page_header();
    $table_text = join "\n", ('<!DOCTYPE html>',
			      '<html>',
			      '<head>',
			      '<title>Page Title</title>',
			      '<script src="tablefilter/tablefilter.js"></script>',
			      '</head>',
			      '<body>');

    $table_text .= "\n\n";
  }

  # Start table
  $table_text .= '<table class="filter_table" style="width:100%">';
  $table_text .= "\n";

  # Add header row
  $table_text .= "  <tr>\n";
  for my $column_head ($self->columns) {
    $table_text .= "    <th>$column_head</th>\n";
  }
  $table_text .= "  </tr>\n";

  # Add each data row
  for my $row ($self->data) {
    $table_text .= "  <tr>\n";

    #Prep column data
    my @column_data;
    if (ref $row eq 'HASH') {
      @column_data = @{$row}{$self->columns};
    }
    elsif (ref $row eq 'ARRAY') {
      @column_data = @{$row};
    }

    # Add each column
    for my $cell_data (@column_data) {

      # Prep cell data
      my ($cell_text, $cell_format);
      if (ref $cell_data eq 'ARRAY') {
	($cell_text, $cell_format) = @{$cell_data};
      }
      else {
	$cell_text = $cell_data;
      }

      # Prep cell format
      my $td_tag;
      if ($cell_format) {
	$td_tag = '<td ';
	my @cell_attrbs;
	for my $attrb (keys %{$cell_format}) {
	  my $attrb_value = $cell_format->{$attrb};
	  push @cell_attrbs, "${attrb}=\"$attrb_value\"";
	}
	$td_tag .= join ' ', @cell_attrbs;
	$td_tag .= '>';
      }
      else {
	$td_tag = '<td>';
      }
      $table_text .= "    ${td_tag}${cell_text}</td>\n";
    }
    $table_text .= "  </tr>\n"
  }

  # End Table
  $table_text .= "</table>\n";

  # Add TableFilter
  $table_text .= join "\n", ('<script>',
			     'var tf = new TableFilter(document.querySelector(\'.filter_table\'), {',
			     '});',
			     'tf.init();',
			     '</script>'
			    );

  if ($self->full_page) {
    # $table_text .= html_page_footer();
    $table_text .= "\n\n";
    $table_text .= join "\n", ('</body>',
			       '</html>');
    $table_text .= "\n";
  }
  return $table_text;
}

#-----------------------------------------------------------------------------

=head2 text_table

 Title   : text_table
 Usage   : text_table(argument);
 Function: Do something
 Returns : Something
 Args    : Something else

=cut

sub text_table {

  throw_msg('method_not_yet_implimented', 'Cirque::TableFilter::text_table');
  my $argument = shift @_;

  my $value = 1;

  return $value;
}

#-----------------------------------------------------------------------------

=head2 rotate_right

 Title   : rotate_right
 Usage   : rotate_right(argument);
 Function: Do something
 Returns : Something
 Args    : Something else

=cut

sub rotate_right {

  throw_msg('method_not_yet_implimented', 'Cirque::TableFilter::rotate_right');
  my $argument = shift @_;

  my $value = 1;

  return $value;
}

#-----------------------------------------------------------------------------

=head2 rotate_left

 Title   : rotate_left
 Usage   : rotate_left(argument);
 Function: Do something
 Returns : Something
 Args    : Something else

=cut

sub rotate_left {

  throw_msg('method_not_yet_implimented', 'Cirque::TableFilter::rotate_left');
  my $argument = shift @_;

  my $value = 1;

  return $value;
}

#-----------------------------------------------------------------------------

=head2 shuffle_rows

 Title   : shuffle_rows
 Usage   : shuffle_rows(argument);
 Function: Do something
 Returns : Something
 Args    : Something else

=cut

sub shuffle_rows {

  throw_msg('method_not_yet_implimented', 'Cirque::TableFilter::shuffle_rows');
  my $argument = shift @_;

  my $value = 1;

  return $value;
}

#-----------------------------------------------------------------------------

=head2 shuffle_columns

 Title   : shuffle_columns
 Usage   : shuffle_columns(argument);
 Function: Do something
 Returns : Something
 Args    : Something else

=cut

sub shuffle_columns {

  throw_msg('method_not_yet_implimented', 'Cirque::TableFilter::shuffle_columns');
  my $argument = shift @_;

  my $value = 1;

  return $value;
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=over

=item C<< failed_to_load_module >>

C<Cirque::TableFilter::load_module> was unable to load (require) the specified
module.  The module may not be installed or it may have a compile time
error.

=back

=head1 CONFIGURATION AND ENVIRONMENT

L<Cirque::TableFilter> requires no configuration files or environment variables.

=head1 DEPENDENCIES

=over

=item L<Carp> qw(croak cluck)

=back

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2019, Barry Moore <barry.moore@genetics.utah.edu>.
All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

1;
