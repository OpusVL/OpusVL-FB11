package OpusVL::CustomParams::Schema::Result::CustomParams;

use strict;
use warnings;
use DBIx::Class::Candy;

# ABSTRACT: Stores parameter schemata to supply to ObjectParams
our $VERSION = '0';

=head1 DESCRIPTION

This class represents a simple table that just stores OpenAPI JSON objects against semantic class names.

=head1 COLUMNS

=head2 type

The semantic type name being augmented with this schema

=head2 schema

A JSON field containng the OpenAPI schema.

=cut

primary_column type => (
    data_type => 'text'
);

column schema => (
    data_type => 'jsonb'
);

1;
