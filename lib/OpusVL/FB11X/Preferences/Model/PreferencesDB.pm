package OpusVL::FB11X::Preferences::Model::PreferencesDB;

use Moose;

BEGIN {
    extends 'Catalyst::Model::DBIC::Schema';
}

__PACKAGE__->config(
    schema_class => 'OpusVL::FB11::Schema::Preferences',
    traits => 'SchemaProxy',
);
1;
