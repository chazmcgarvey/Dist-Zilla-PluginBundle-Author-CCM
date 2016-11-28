package Pod::Weaver::PluginBundle::Author::CCM;
# ABSTRACT: A plugin bundle for pod woven by CCM

=head1 SYNOPSIS

    # In your weaver.ini file:
    [@Author::CCM]

    # In your dist.ini file:
    [PodWeaver]
    config_plugin = @Author::CCM

=head1 DESCRIPTION

You probably don't want to use this.

=head1 SEE ALSO

=for :list
* L<Pod::Weaver>
* L<Pod::Weaver::PluginBundle::Author::ETHER>

=head1 CREDITS

This module was heavily inspired by Karen Etheridge's config.

=cut

use 5.008;
use warnings;
use strict;

our $VERSION = '999.999'; # VERSION

use Pod::Weaver::Config::Assembler;
use namespace::autoclean;

=method configure

Returns the configuration in a form similar to what one might use with
L<Dist::Zilla::Role::PluginBundle::Easy/add_plugins>.

=cut

sub configure {
    return (
        ['-EnsurePod5'],
        ['-H1Nester'],
        ['-SingleEncoding'],

        ['-Transformer' => List     => {transformer => 'List'}],
        ['-Transformer' => Verbatim => {transformer => 'Verbatim'}],

        ['Region' => 'header'],

        'Name',
        # ['Badges' => {badge => [qw(perl travis coverage)], formats => 'html, markdown'}],

        'Version',

        ['Region' => 'prelude'],

        ['Generic' => 'SYNOPSIS'],
        ['Generic' => 'DESCRIPTION'],
        ['Generic' => 'OVERVIEW'],
        ['Collect' => 'ATTRIBUTES' => {command => 'attr'}],
        ['Collect' => 'METHODS'    => {command => 'method'}],
        ['Collect' => 'FUNCTIONS'  => {command => 'func'}],

        'Leftovers',

        ['Region' => 'postlude'],

        'Bugs',
        'Authors',
        'Contributors',
        'Legal',

        ['Region' => 'footer'],
    );
}

=method mvp_bundle_config

Required in order to be a plugin bundle.

=cut

sub mvp_bundle_config {
    my $self = shift || __PACKAGE__;

    return map { $self->_expand_config($_) } $self->configure;
}

sub _exp { Pod::Weaver::Config::Assembler->expand_package($_[0]) }

sub _expand_config {
    my $self = shift;
    my $spec = shift;

    my ($name, $package, $payload);

    if (!ref $spec) {
        ($name, $package, $payload) = ($spec, $spec, {});
    }
    elsif (@$spec == 1) {
        ($name, $package, $payload) = (@$spec[0,0], {});
    }
    elsif (@$spec == 2) {
        ($name, $package, $payload) = ref $spec->[1] ? @$spec[0,0,1] : (@$spec[1,0], {});
    }
    else {
        ($package, $name, $payload) = @$spec;
    }

    $name =~ s/^[@=-]//;
    $package = _exp($package);

    if ($package eq _exp('Region')) {
        $name = $spec->[1];
        $payload = {region_name => $spec->[1], %$payload};
    }

    $name = '@Author::CCM/' . $name if $package ne _exp('Generic') && $package ne _exp('Collect');

    return [$name => $package => $payload];
}

1;
