package OpusVL::FB11::FormHandler::Trait::Field::DateTime;

use Moose::Role;
use Data::Munge qw/elem/;

has not_before => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_not_before',
);

has not_after => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_not_after',
);

has dt_date => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);

has dt_time => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);

has dt_mask => (
    is => 'rw',
    isa => 'Bool',
);

has date_format => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_date_format',
);

around element_attr => sub {
    my $orig = shift;
    my $self = shift;

    my ($attr) = $self->$orig(@_);

    $attr->{'data-dt-not-after'} = $self->not_after
        if $self->has_not_after;

    $attr->{'data-dt-not-before'} = $self->not_before
        if $self->has_not_before;

    $attr->{'data-dt-mask'} = $self->dt_mask
        if $self->dt_mask;

    $attr->{'data-dt-format'} = $self->date_format
        if $self->has_date_format;

    return $attr;
};

around element_class => sub {
    my $orig = shift;
    my $self = shift;

    my ($classes) = $self->$orig(@_);

    push @$classes, 'datepicker' if $self->dt_date and not elem 'datepicker', $classes;
    push @$classes, 'timepicker' if $self->dt_time and not elem 'timepicker', $classes;

    return $classes;
};

1;
