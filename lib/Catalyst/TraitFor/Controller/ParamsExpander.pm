package Catalyst::TraitFor::Controller::ParamsExpander;
# ABSTRACT: Expand params data structures into perl ones

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

before 'auto' => sub {
    my ( $self, $c ) = @_;

    if ( my $params = $c->req->params ) {
        for my $name ( keys %{$c->req->params} ) {
            if ( $name =~ /^ (.+?) ( (?:\[ [^\]]+ \])+ ) $/x ) {
                my $param = \$params->{$1};
                my $nest = $2;
                while ( $nest =~ /\[ (\S+?) \]/gx ) {
                    my $idx = $1;
                    if ( $idx =~ /^\d+$/ ) {
                        $param = \($$param->[$idx]);
                    }
                    else {
                        $param = \($$param->{$idx});
                    }
                }
                $$param = $params->{$name};
            }
        }
    }
};

sub auto : Private { 1 }

1;

=head1 SYNOPSIS

In your controller ( Apply to root controller to be application wide )

    package MyApp::Controller::Root;
    use Moose;
    use namespace::autoclean;

    BEGIN { extends 'Catalyst::Controller' }
    with 'Catalyst::TraitFor::Controller::ParamsExpander';

    # ...

    1;

=head1 DESCRIPTION

This controller role will provide params expansion for nested structures very common when
serializing javascript data structures with jQuery. This kind of serialization is also used
by several php form handlers and the rails framework.

Once in use, you'll get all nested params expanded into perl data structures.

For example, when the original $c->req->params hashref looks like this:

    {
        'city[0][name]'  => 'Madrid',
        'city[0][group]' => 'madrid.pm',
        'city[1][name]'  => 'Buenos Aires',
        'city[1][group]' => 'cafe.pm',
        'city[2][name]'  => 'Barcelona',
        'city[2][group]' => 'barcelona.pm',
    }

You'll get this:

    {
        city => [
            { name => 'Madrid',       group => 'madrid.pm'},
            { name => 'Buenos Aires', group => 'cafe.pm'},
            { name => 'Barcelona',    group => 'barcelona.pm'}
        ],
        'city[0][name]'  => 'Madrid',
        'city[0][group]' => 'madrid.pm',
        'city[1][name]'  => 'Buenos Aires',
        'city[1][group]' => 'cafe.pm',
        'city[2][name]'  => 'Barcelona',
        'city[2][group]' => 'barcelona.pm',
    }

=method auto

The params expansion will happen before the controller 'auto' action.

=head1 SEE ALSO

=for :list
* L<Catalyst::Plugin::Params::Nested>
* L<Catalyst::TraitFor::Request::Params::Hashed>

