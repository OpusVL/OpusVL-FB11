package OpusVL::ObjectParams;

use v5.24;
use warnings;
use strict;

use Moose;

has short_name => (
    is => 'ro',
    default => 'objectparams'
);

with 'OpusVL::FB11::Role::Brain';

# ABSTRACT: Module to handle extensions to others' core data.
our $VERSION = '0';

=head1 DESCRIPTION

Like L<OpusVL::SysParams>, this module's purpose is to allow an application or
component to register extensions to another component's core data, and to define
the schema by which that is achieved. The purpose of this is to ensure that the
needs of a component can be met before the application gets to the point where
it's happily running, oblivious to its impending crash.

This module orchestrates two sets of Brains: those with extensible data
(I<extendees>), and those providing extensions (I<extenders>).

=head1 SYNOPSIS

    package MyComponent::Brain;

    # ... brain boilerplate ...

    sub hats {
        'objectparams::extendee'
    }

Z<>

    package MyComponent::Brain::Hat::objectparams::extendee;

    sub extendee_spec {
        'mycomponent::somedata' => {
            class => 'MyComponent::Schema::Result::SomeData',
            driver => 'dbic'
        }
    }

Z<>

    package AnotherComponent::Brain;

    # ...
    sub hats {
        'objectparams::extender'
    }

Z<>

    package AnotherComponent::Brain::Hat::objectparams::extender;

    sub schemas {
        'mycomponent::somedata' => {
            # ... OpenAPI Spec
        }
    }

    sub parameters_for {
        my $self = shift;
        my $type = shift;
        my $key = shift;

        my $rs = $self->__brain->schema->parameters_resultset($type);
        $rs->parameters_for($key);
    }

=head1 EXTENDING DATA

=head2 Extendees

For more information on Extendees, see
L<OpusVL::ObjectParameters::Role::Hat::objectparams::extendee>.

It is not strictly necessary to export any information about extendable objects.
Any Brain can, in theory, extend any other Brain's objects if it wants to. The
strict difference is that if you are declaring your objects as extendable, I<you
will be looking for them>.

Generally, this means that you will provide a form (probably in a separate UI
module, but still under your control), or at least some sort of behaviour, that
can make use of extensions to your object.

When you declare your objects as being extensible, you give them semantic names.
This is usually represented as a namespaced short name, for example
C<fb11core::user> would represent the core FB11 user object.

(Note that this interface also avoids exposing any knowledge about I<how> the
C<fb11core::user> object is represented. This supports the later possibility of
replacing the source of this data while maintaining compatibility with existing
extensions.)

=head3 Wear the C<objectparams::extendee> hat

A Brain with extensible objects would wear the C<objectparams::extendee> hat,
and implement it. The implementation provides a single method, C<extendee_spec>,
which returns a hashref keyed on the aforementioned semantic names, with values
configuring the Parameters service itself.

=head3 Parameter configuration

An example hashref looks like this:

    {
        'fb11core::user' => {
            # TODO
            driver => 'dbic'
        }
    }

We explain drivers further down. Normally the name would represent the I<type>
of object your extensible object is, but some drivers might represent behaviour
specific to an individual class or component.

=head2 Extenders

For more information on Extenders, see
L<OpusVL::ObjectParameters::Role::Hat::objectparams::extender>.

An I<Extender>, on the other hand, declares that it has extensions for the
objects named by the extendee's Parameters configuration.

The extension is twofold. First, in the abstract sense, the extender declares an
OpenAPI schema defining the extra data that will be added onto the type. This
can be read by anything that cares. Second, the extender accepts a I<type> and a
I<key> for an object being extended, and either stores or returns the extended
data.

=head3 Define an OpenAPI schema

The idea is that you add data that you are going to use. You are responsible for
correctly defining the schema, and for storing and retrieving the extension you
say you provide.

The component that owns the object - the one that provides the semantic name for
it - will be responsible for marshalling the data. It will render the form, or
otherwise collect user data, and merge your extension data with its own whenever
the object is rendered.

That component is unlikely to make any further use of your data, because it
doesn't know what it is for.

=head3 Wear the C<objectparams::extender> hat

Wear, and define, a Hat of this type.  Your Hat will be responsible for
retrieving data for an object, and storing it. The data you return, or receive,
will conform to your OpenAPI schema.

This hat requires three methods. The first two of them are used to set and
retrieve extension data; the third defines the OpenAPI schemata you will conform
to, and associates them with the semantic names from the component(s) you are
extending.

=head4 C<schemas>

This returns a hash-shaped list of OpenAPI specifications, a concept out of
scope of this document. Each schema defines the parameters that your Hat
associates with the object identified by the key.

    sub schemas {
        'fb11core::user' => {
            # OpenAPI spec
        }
    }

By mentioning that object type as a key, the Parameters Brain knows that you
will accept and return parameters for it.

=head4 C<get_parameters_for>, C<set_parameters_for>

These methods are provided for you by the role
L<OpusVL::ObjectParams::Role::Hat::objectparams::extender>. By default they just
store and retrieve the data using the built-in storage mechanism. However, you
can override them if you want to handle the data in a customised way.

Both of these methods will receive a C<$type> and an C<$identifier>. C<$type>
will be a string corresponding to one of the types you said you could handle in
C<schemas>. C<$identifier> will be a unique way to identify the object of that
type. See L</DRIVERS> for how the identifier is produced.

Naturally, C<set_parameters_for> will also receive a hashref conforming to the
OpenAPI specification you defined in C<schemas>, and C<get_parameters_for> is
expected to return a similar hashref.

=head2 Extensibles

An object that can be extended makes itself I<extensible> by means of adapter
objects.

An adapter object is an object that contains, in this case, the object being
extended. Communication with the C<objectparams> service is done by putting your
extensible object into an adapter and then sending that to the service.

=head3 Adapters

The adapters are used to tell the service a) the type of the object and b) the
identifier. The simplest adapter is the I<static> adapter, which does not
actually contain the extensible object at all, and simply has these two data
items as properties on the adapter itself.

    OpusVL::FB11::Hive->service('objectparams')->get_extensions_for(
        OpusVL::ObjectParams::Adapter::Static(
            type => 'fb11core::user',
            id => $user->id_for_params
        )
    );

Other adapter types can be used as convenient ways of interfacing with common
object types.

=head3 Extensible Role

The L<OpusVL::ObjectParameters::Role::Extensible|Extensible Role> can be applied
to a class to expose the C<extension_adapter> method on the object itself. This
can either be implemented by the object, by another role, or by an extension of
the Extensible Role that implements a specific adapter type.

=head1 THE SERVICE

The C<objectparams> service is documented in
L<OpusVL::ObjectParams::Hat::objectparams>.

=cut

sub hats {
    'objectparams'
}

sub provided_services {
    'objectparams'
}

sub hive_init {
    my $self = shift;
    my $hive = shift;

    # Check all objectparams::extendees and see that we have a service
    # corresponding to their drivers.
}

1;
