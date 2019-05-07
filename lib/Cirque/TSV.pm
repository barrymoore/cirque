package Cirque::TSV;

use base qw(Cirque::Base);

use strict;
use warnings;
use vars qw($VERSION);

$VERSION = 0.0.1;

=head1 NAME

Cirque::TSV - Parse tab-delimited text files with headers.

=head1 VERSION

This document describes Cirque::TSV version 0.0.1

=head1 SYNOPSIS

    use Cirque::TSV;
    my $parser = Cirque::TSV->new('tsv_header.txt');

    while (my $record = $parser->next_record) {
	print $record->{column_name_A}) . "\n";
    }

=head1 DESCRIPTION

L<Cirque::TSV> provides TSV (tab-delimited text file) parsing ability
for the cirque suite of text data tools.  While the name indicates
tab-delimited text, any delimiter can be used. However some formats
such as CSV have additional requirements (i.e. handling quoted data)
and changing the delimiter to e.g. to a comma does not make this a
full CSV parser - it doesn't care about quoting or anything but
delimited text data.  The modual also expects the data file to have a
header, although this constraint can be met by providing column names
as an argument to the constructor.


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
	$self->_process_header;
	return $self;
}

#-----------------------------------------------------------------------------
#----------------------------- Private Methods -------------------------------
#-----------------------------------------------------------------------------

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
  my @valid_attributes = qw(columns delimiter header_reqex preheader_regexp);
  $self->set_attributes($args, @valid_attributes);
  ######################################################################
}

=head2 _process_header

  Title   : _process_header
  Usage   : $self->_process_header
  Function: Parse and store header data
  Returns : N/A
  Args    : N/A

=cut

sub _process_header {
  my $self = shift @_;

  my $delimiter = $self->delimiter;
  my $header_regexp = $self->header_regexp;
  my $skip_regexp = $self->skip_regexp;
 LINE:
  while (my $line = $self->readline) {
    return undef if ! defined $line;

    if ($line =~ /$skip_regexp/) {
      push @{$self->{skipped}}, $line;
      undef($line);
      next LINE;
    }
    elsif ($line =~ /$header_regexp/) {
      push @{$self->{header}}, $line;
      $line =~ s/${$self->header_regexp}//;
      chomp $line;
      my @cols = split /$delimiter/, $line;
      $self->columns(\@cols);
      undef($line);
      last LINE;
    }
  }
}

#-----------------------------------------------------------------------------
#-------------------------------- Attributes ---------------------------------
#-----------------------------------------------------------------------------

=head2 columns

 Title   : columns
 Usage   : $columns = $self->columns(qw(column1 columnB third_column));
 Function: Get/set columns
 Returns : An columns value
 Args    : An columns value

=cut

sub columns {
  my ($self, $columns) = @_;

  if ($columns) {
    $self->{columns} = $columns;
  }

  return wantarray ? @{$self->{columns}} : $self->{columns};
}

#-----------------------------------------------------------------------------

=head2 delimiter

 Title   : delimiter
 Usage   : $delimiter = $self->delimiter(qr/\t/);
 Function: Get/set delimiter
 Returns : An delimiter value
 Args    : An delimiter value

=cut

sub delimiter {
  my ($self, $delimiter) = @_;

  if ($delimiter) {
    $delimiter = qr/$delimiter/
      unless ref $delimiter eq 'Regexp';
    $self->{delimiter} = $delimiter;
  }

  # Set default value
  if (! exists $self->{delimiter} || ! defined $self->{delimiter}) {
    $self->{delimiter} = qr/\t/;
  }

  return $self->{delimiter};
}

#-----------------------------------------------------------------------------

=head2 header_regexp

 Title   : header_regexp
 Usage   : $header_regexp = $self->header_regexp(qr/^\#/);
 Function: Get/set header_regexp
 Returns : The header_regexp value
 Args    : A header_regexp value

=cut

sub header_regexp {
  my ($self, $header_regexp) = @_;

  if ($header_regexp) {
    $header_regexp = qr/$header_regexp/
      unless ref $header_regexp eq 'Regexp';
    $self->{header_regexp} = $header_regexp;
  }

  # Set default value
  if (! exists $self->{header_regexp} || ! defined $self->{header_regexp}) {
    $self->{header_regexp} = qr/^#\s*/;
  }

  return $self->{header_regexp};
}

#-----------------------------------------------------------------------------

=head2 skip_regexp

 Title   : skip_regexp
 Usage   : $skip_regexp = $self->skip_regexp(qr/^\#/);
 Function: Get/set skip_regexp
 Returns : The skip_regexp value
 Args    : A skip_regexp value

=cut

sub skip_regexp {
  my ($self, $skip_regexp) = @_;

  if ($skip_regexp) {
    $skip_regexp = qr/$skip_regexp/
      unless ref $skip_regexp eq 'Regexp';
    $self->{skip_regexp} = $skip_regexp;
  }

  # Set default value
  if (! exists $self->{skip_regexp} || ! defined $self->{skip_regexp}) {
    $self->{skip_regexp} = qr/^##/;
  }

  return $self->{skip_regexp};
}

#-----------------------------------------------------------------------------

#  =head2 attribute
#
#   Title   : attribute
#   Usage   : $attribute = $self->attribute($attribute);
#   Function: Get/set attribute
#   Returns : An attribute value
#   Args    : An attribute value
#
#  =cut
#
#  sub attribute {
#    my ($self, $attribute) = @_;
#
#    if ($attribute) {
#      $self->{attribute} = $attribute;
#    }
#
#    return $self->{attribute};
#  }

#-----------------------------------------------------------------------------
#---------------------------------- Methods ----------------------------------
#-----------------------------------------------------------------------------

=head2 next_record

 Title   : next_record
 Usage   : $record = $tsv_header->next_record();
 Function: Return the next record from the TSV file.
 Returns : A hash (or reference) of TSV record data.
 Args    : N/A

=cut

sub next_record {
  my $self = shift @_;

  my $skip_regexp = $self->skip_regexp;

  my $line;
 LINE:
  while (! $line) {
    $line = $self->readline;
    last LINE if ! defined $line;
    if ($line =~ /$skip_regexp/) {
      push @{$self->{skipped}}, $line;
      undef($line);
      next LINE;
    }
  }
  return undef if ! defined $line;

  my $record = $self->parse_record($line);

  return wantarray ? %{$record} : $record;
}

#-----------------------------------------------------------------------------

=head2 parse_record

 Title   : parse_record
 Usage   : $record = $tsv_header->parse_record();
 Function: Return the next record from the TSV file.
 Returns : A hash (or reference) of TSV record data.
 Args    : N/A

=cut

sub parse_record {
  my ($self, $line) = @_;

  my $delimiter = $self->delimiter;

  chomp $line;
  my %record;
  @record{($self->columns)} = split /$delimiter/, $line;

  return wantarray ? %record : \%record;
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

L<Cirque::TSV> does not throw any warnings or errors.

=head1 CONFIGURATION AND ENVIRONMENT

L<Cirque::TSV> requires no configuration files or environment variables.

=head1 DEPENDENCIES

L<Cirque>

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
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut

1;
