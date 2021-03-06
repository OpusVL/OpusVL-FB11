package OpusVL::FB11::Form;

use v5.24;
use OpusVL::FB11::Plugin::FormHandler;
use Data::Munge qw/elem/;
use PerlX::Maybe;

our $VERSION = '2';

# ABSTRACT: Place to hold form-based functions

=head1 DESCRIPTION

This is an empty form that can be used to create an FB11 form from a field list,
without having to create a new class for it.

It also has class methods for constructing forms.

=head1 CLASS METHODS

=head2 new_from_openapi

B<Arguments>: C<%$schema>, C<%$hfh_args>?

Creates a new form from an OpenAPI schema object. This just defers to
L</openapi_to_field_list> and uses the result as the C<field_list> of a new
form.

You can also supply the rest of the options to HTML::FormHandler->new in the
second parameter, including another C<field_list>, which will be added I<before>
the fields from the schema.

=cut

sub new_from_openapi {
    my $class = shift;
    my $schema = shift;
    my $hfh_args = shift || {};

    my $field_list = $class->openapi_to_field_list($schema);

    if (my $to_merge = $hfh_args->{field_list}) {
        $field_list = [ @$to_merge, @$field_list ];
    }

    $hfh_args->{field_list} = $field_list;

    return $class->new($hfh_args);
}

=head2 openapi_to_field_list

B<Arguments>: C<%$openapi_schema>

B<Returns>: C<@%formhandler_fields>

Converts the OpenAPI Schema object into a FormHandler field definition arrayref.

=cut

sub openapi_to_field_list {
    my $class = shift;
    my $schema = shift;

    # TODO - this could become very complicated. Eventually we will be wanting
    # to add custom field types to this array so that the form validates the
    # openapi spec.
    # It might be better to create a suite of fields for formhandler that work
    # with the openapi spec.
    my $formhandler = [];

    my $order = $schema->{'x-field-order'} // [ sort keys $schema->{properties}->%* ];
    my $required = $schema->{required} // [];

    my $namespace = $schema->{'x-namespace'} // '';

    for my $field (@$order) {
        my $def = $schema->{properties}->{$field};

        # TODO validation
        my %field = (
            label => $def->{title} // $field,
      maybe default => $def->{default},
      maybe readonly => $def->{'x-readonly'},
        );

        if (elem $field, $required) {
            $field{required} = 1;
        }

        if ($def->{'x-hidden'}) {
            $field{type} = 'Hidden';
        }
        elsif (my $options = $def->{'x-options'}) {
            $field{type} = 'Select';
            $field{options} = $options;
            if ($def->{type} eq 'array') {
                $field{multiple} = 1;
            }
        }
        else {
            $field{type} = _to_field_type($def->{type});
        }

        # TODO - semantic widgets?
        if (my $w = $def->{'x-widget'}) {
            $field{widget} = $w;
        }

        if (my $real_def = $def->{items}) {
            if (my $opts = $real_def->{enum}) {
                $field{options} = [ map +{
                    value => $_, label => $_
                }, @$opts ]
            }
            $field{multiple} = 1;
        }

        push @$formhandler, ( _with_namespace($namespace, _to_field_name($field)) => \%field )
    }

    return $formhandler;
}

=head2 openapi_to_init_object

B<Arguments>: C<%$openapi_schema>, C<%$init_object>

Given the same schema you might pass to L</openapi_to_field_list>, converts an
object that conforms to that schema into an object that can be used as the
C<init_object> for a FormHandler form.

This is a way of translating field names.

=cut

sub openapi_to_init_object {
    my $class = shift;
    my $schema = shift;
    my $init_object = shift;

    my $output_object = shift;

    my $namespace = $schema->{'x-namespace'} // '';

    return {
        map {
            _with_namespace($namespace, _to_field_name($_)) => $init_object->{$_}
        }
        keys %$init_object
    }
}

=head1 METHODS

Intended to be run on the object, not the class

=head2 values_for_openapi_schema

B<Arguments>: C<%$openapi_schema>

B<Returns>: C<%$compliant_hashref>

Given that we converted an OpenAPI schema to a form using its namespace and
sanitised field names, this will pluck those field names out of the form and
produce an object that conforms to the schema.

Due to the fact we munged the field names in the first place, it is not entirely
guaranteed that this process is reversible; but it should be. Problems are the
responsibility of the schema creator.

=cut

sub values_for_openapi_schema {
    my $self = shift;
    my $schema = shift;

    my $namespace = $schema->{'x-namespace'} // '';

    my $ret = {};

    for my $field (keys $schema->{properties}->%*) {
        my $form_field = _with_namespace($namespace, _to_field_name($field));

        my $value = $self->field($form_field)->value;

        if ($schema->{properties}->{$field}->{type} eq 'array'
        and not ref $value) {
            $value = [ $value ]
        }

        $ret->{$field} = $value;
    }

    return $ret;
}

# Adds the namespace to the field. This lets us change in a single place how
# namespaces are represented.
# TODO we should formalise namespaces, but I don't know how yet.
sub _with_namespace {
    my $namespace = shift;
    my $field_name = shift;

    return $field_name if not $namespace;

    return $namespace . '::' . $field_name
}

# sanitises the field name into lowercase_underscore
sub _to_field_name {
    my $badname = shift;
    return lc $badname =~ s/^\s+|\s+$//gr =~ s/\s+/_/gr;
}

# Returns an appropriate FormHandler field type for the OpenAPI type
sub _to_field_type {
    state %mapping = (
        string => 'Text',
        array => 'Select',
        boolean => 'Checkbox',
        # FIXME This field type doesn't exist.
        # We will have to use the format information to know which type to use.
        # This is the point at which we make a proper class structure for it.
        # number => 'Number',
    );

    my $openapi_name = shift;
    # TODO
    return $mapping{$openapi_name} || die "I don't know how to render $openapi_name";
}

1;
