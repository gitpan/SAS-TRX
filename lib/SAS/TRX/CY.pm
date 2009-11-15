package SAS::TRX::CY;
#
#	Format TRX-learned structure into CSV + YAML
#

use strict;
use warnings;

use base qw(SAS::TRX);
use IO::File;

#
#	Constructor
#
sub new
{
	my $class	= shift;
	my %param	= @_;

	my $self	= $class->SUPER::new(@_);

	# Open destination files
	foreach my $dst (qw(DATASET STRUCT)) {
		if ($param{$dst}) {
			$self->{$dst} = new IO::File $param{$dst}, 'w';
		}
	}

	bless ($self,$class);
        return $self;
}


#
#	Can be used to construct data a row header
#
sub data_header
{
	my $self	= shift;
	my $dsname	= shift;

	print  { $self->{DATASET} }
		join("\t", $dsname, @{$self->{TRX}{$dsname}{CNAMES}}),
		"+\n";
}

#
#	Create an INSERT line for a given dataset and list of data values
#
sub data_row
{
	my $self	= shift;

	my $dsname	= shift;
	my $row		= shift;

	print { $self->{DATASET} } join("\t", map { defined $_ ? $_ : 'NULL'} @{ $row }), "-\n";
}

use YAML qw/Dump/;

sub data_description
{
	my $self	= shift;

	my %struct;

	foreach my $tbl (keys %{$self->{TRX}}) {
		foreach my $var (@{ $self->{TRX}{$tbl}{VAR} }) {
			push @{ $struct{$tbl} },
				{
				NAME => $var->{NNAME},
				TYPE => $var->{NTYPE} == 1 ? 'NUMBER' : 'CHAR',
				LABEL=> $var->{NLABEL},
				};
		}
	}
	print { $self->{STRUCT} } Dump(\%struct);
}

1;

__END__

=head1 NAME

SAS::TRX::CY - Convert a TRX library into a YAML file with data description and
a CSV file with data.

=head1 SYNOPSIS

  use SAS::TRX::CY;

  my $cy = new SAS::TRX::CY DATASET=>'trx.csv', STRUCT=>'trx.yml';
  $cy->load('source.trx');

=head1 DESCRIPTION


Parses 'source.trx' and splits onto DATASET and STRUCT files. Make sure you have
write access permission to the destination files.

=head2 EXPORT

Nothing is exported.


=head1 SEE ALSO

SAS::TRX for the base class


=head1 AUTHOR

Alexander Kuznetsov, E<lt>acca@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Alexander Kuznetsov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
