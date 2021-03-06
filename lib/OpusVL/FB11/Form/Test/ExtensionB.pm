package OpusVL::FB11::Form::Test::ExtensionB;

our $VERSION = '2';

use OpusVL::FB11::Plugin::FormHandler;
with 'HTML::FormHandler::TraitFor::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default => 'Author' );

has_field 'foo' => ( type => 'Text', label => 'Foo' );
has_field 'author' => ( type => 'Select', label => 'Authors' );


has_field 'submitbutton' => (
	type	=> 'Submit',
	widget  => 'ButtonTag',
	widget_wrapper => 'None',
	value 	=> '<i class="fa fa-check"></i> Submit',
	element_attr => { value => 'submit_roles', class => ['btn', 'btn-success'] }
);

no HTML::FormHandler::Moose;
1;
__END__
