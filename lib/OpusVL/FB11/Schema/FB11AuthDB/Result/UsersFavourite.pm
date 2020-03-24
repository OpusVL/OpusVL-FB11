use utf8;
package OpusVL::FB11::Schema::FB11AuthDB::Result::UsersFavourite;

our $VERSION = '1';

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OpusVL::FB11::Schema::Result::UsersFavourite

=cut

use strict;
use warnings;
no warnings 'experimental::signatures';;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<users_favourites>

=cut

__PACKAGE__->table("users_favourites");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 page

  data_type: 'varchar'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "page",
  { data_type => "varchar", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07041 @ 2015-01-30 10:50:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/FwXrF3sQMiB2vOPCFpP8g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
