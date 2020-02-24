package OpusVL::FB11::Schema::FB11AuthDB::Result::RoleAdmin;

our $VERSION = '1';

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;
no warnings 'experimental::signatures';;

use base 'DBIx::Class::Core';


=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::RoleAdmin

=cut

__PACKAGE__->table("role_admin");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "role_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
  },
);
__PACKAGE__->set_primary_key("role_id");

=head1 RELATIONS

=head2 role

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::Role",
  { id => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 15:49:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fPKUkJjNsc6+1uVUcBMElw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
