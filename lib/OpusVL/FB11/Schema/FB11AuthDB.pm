package OpusVL::FB11::Schema::FB11AuthDB;

use strict;
use warnings;
no warnings 'experimental::signatures';;
our $VERSION = '2';

use Moose;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable;

sub schema_version { 2 }

1;
