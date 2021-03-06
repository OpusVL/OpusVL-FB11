package OpusVL::FB11X::CustomParams::Controller::CustomParams;

# ABSTRACT: Allows editing of (basic) ObjectParams schemata
our $VERSION = '2';

use strict;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use HTML::Entities;
use OpusVL::FB11::Hive;

BEGIN { extends 'Catalyst::Controller'; }
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name          => 'Admin',
    fb11_icon          => 'cog',
    fb11_myclass       => 'OpusVL::FB11X::CustomParams',
    fb11_shared_module => 'Admin',
    fb11_method_group  => 'System',
);

has_forms (
    edit_form => 'Schema'
);

# I'm calling it "Object Parameters" in the menu because that's what we're
# building. "Custom Parameters" is not as meaningful on the frontend.
sub list_types
    : Path(list-types)
    : NavigationName('Object Parameters')
    : FB11Feature('Object Parameters')
{
    my ($self, $c) = @_;

    $c->stash->{types} = [
        OpusVL::FB11::Hive
            ->service('customparams')
            ->available_types
    ];
}

sub edit_schema
    :Path('edit-schema')
    :Args(1)
    :FB11Feature('Object Parameters')
{
    my ($self, $c, $type) = @_;
    my $service = OpusVL::FB11::Hive->service('customparams');
    my $form = $c->stash->{form} = $self->edit_form;

    $form->process(
        params => $c->req->params,
        posted => $c->req->method eq 'POST',
        init_object => $form->from_openapi($service->get_schema_for($type)),
    );

    if ($form->validated) {
        $service->set_schema_for($type, $form->to_openapi);

        $c->res->redirect($c->req->uri);
    }

}

1;
