package Dist::Zilla::PluginBundle::TestingMania;
# ABSTRACT: test your dist with every testing plugin conceivable
use strict;
use warnings;
use 5.010001; # We use the smart match operator
our $VERSION = '0.010'; # VERSION

use Dist::Zilla::Plugin::Test::CPAN::Changes            qw();
use Dist::Zilla::Plugin::CompileTests                   qw();
use Dist::Zilla::Plugin::ConsistentVersionTest          qw();
use Dist::Zilla::Plugin::CriticTests 1.102280           qw();
use Dist::Zilla::Plugin::DistManifestTests              qw();
use Dist::Zilla::Plugin::EOLTests 0.02                  qw(); # Also checks for trailing whitespace
use Dist::Zilla::Plugin::HasVersionTests                qw();
use Dist::Zilla::Plugin::KwaliteeTests                  qw();
use Dist::Zilla::Plugin::MetaTests                      qw();
use Dist::Zilla::Plugin::MinimumVersionTests            qw();
use Dist::Zilla::Plugin::NoTabsTests                    qw();
use Dist::Zilla::Plugin::PodCoverageTests               qw();
use Dist::Zilla::Plugin::PodSyntaxTests                 qw();
use Dist::Zilla::Plugin::PortabilityTests               qw();
use Dist::Zilla::Plugin::SynopsisTests                  qw();
use Dist::Zilla::Plugin::UnusedVarsTests                qw();
use Dist::Zilla::Plugin::Test::Pod::LinkCheck           qw();
use Dist::Zilla::Plugin::Test::CPAN::Meta::JSON 0.003   qw(); # Prunes itself when META.json isn't present


use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

sub configure {
    my $self = shift;

    my %plugins = (
        'Test::CPAN::Changes'   => $self->config_slice('changelog'),
        'Test::CPAN::Meta::JSON'=> 1, # prunes itself if META.json isn't there
        'Test::Pod::LinkCheck'  => 1,
        CompileTests            => 1,
        ConsistentVersionTest   => 0, # finnicky and annoying
        CriticTests             => 1,
        DistManifestTests       => 1,
        EOLTests                => 1,
        HasVersionTests         => 1,
        KwaliteeTests           => 1,
        MetaTests               => 1, # should only be loaded if MetaYAML is loaded, or the file exists in the dist
        MinimumVersionTests     => 1,
        NoTabsTests             => 1,
        PodCoverageTests        => 1,
        PodSyntaxTests          => 1,
        PortabilityTests        => 1,
        SynopsisTests           => 1,
        UnusedVarsTests         => 1,
    );
    my @include = ();

    my @disable = $self->payload->{disable}
        ? split(/, ?/, $self->payload->{disable})
        : ();
    foreach my $plugin (keys %plugins) {
        next if (                   # Skip...
            $plugin ~~ @disable or  # plugins they asked to skip
            $plugin ~~ @include or  # plugins we already included
            !$plugins{$plugin}      # plugins in the list, but which we don't want to add
        );
        push(@include, ref $plugins{$plugin}
            ? [ $plugin => $plugins{$plugin} ]
            : $plugin);
    }

    my @enable = $self->payload->{enable}
        ? split(/, ?/, $self->payload->{enable})
        : ();
    foreach my $plugin (@enable) {
        next unless $plugin ~~ %plugins; # Skip the plugin unless it is in the list of actual testing plugins
        push(@include, $plugin) unless ($plugin ~~ @include or $plugin ~~ @disable);
    }

    $self->add_plugins(@include);
}

__PACKAGE__->meta->make_immutable();

no Moose;


__END__
=pod

=encoding utf-8

=head1 NAME

Dist::Zilla::PluginBundle::TestingMania - test your dist with every testing plugin conceivable

=head1 VERSION

version 0.010

=head1 SYNOPSIS

In F<dist.ini>:

    [@TestingMania]

=head1 DESCRIPTION

This plugin bundle collects all the testing plugins for L<Dist::Zilla> which
exist (and are not deprecated). This is for the most paranoid people who
want to test their dist seven ways to Sunday.

Simply add the following near the end of F<dist.ini>:

    [@TestingMania]

It includes the most recent version (as of release time) of the following
plugins, in their default configuration. Note that not all the plugins
are actually I<used> by default.

=head2 Testing plugins

=over 4

=item *

L<Dist::Zilla::Plugin::CompileTests>, which performs tests to syntax check your
dist.

=item *

L<Dist::Zilla::Plugin::ConsistentVersionTest>, which tests that all modules in
the dist have the same version. See L<Test::ConsistentVersion> for details. This
is not enabled by default; see L</"Enabling Tests">.

=item *

L<Dist::Zilla::Plugin::CriticTests>, which checks your code against best
practices. See L<Perl::Critic> for details.

=item *

L<Dist::Zilla::Plugin::DistManifestTests>, which tests F<MANIFEST> for
correctness. See L<Test::DistManifest> for details.

=item *

L<Dist::Zilla::Plugin::EOLTests>, which ensures the correct line endings are
used (and also checks for trailing whitespace). See L<Test::EOL> for details.

=item *

L<Dist::Zilla::Plugin::HasVersionTests>, which tests that your dist has version
numbers. See L<Test::HasVersion> for what that means.

=item *

L<Dist::Zilla::Plugin::KwaliteeTests>, which performs some basic kwalitee checks.
I<Kwalitee> is an automatically-measurable guage of how good your software is.
It bears only a B<superficial> resemblance to the human-measurable guage of
actual quality. See L<Test::Kwalitee> for a description of the tests.

=item *

L<Dist::Zilla::Plugin::MetaTests>, which performs some extra tests on
F<META.yml>. See L<Test::CPAN::Meta> for what that means.

=item *

L<Dist::Zilla::Plugin::Test::CPAN::Meta::JSON>, which performs some extra tests
on F<META.json>, if it exists. See L<Test::CPAN::Meta::JSON> for what that
means.

=item *

L<Dist::Zilla::Plugin::MinimumVersionTests>, which tests for the minimum
required version of perl. See L<Test::MinimumVersion> for details, including
limitations.

=item *

L<Dist::Zilla::Plugin::NoTabsTests>, which ensures you don't use I<The Evil
Character>. See L<Test::NoTabs> for details. If you wish to exclude this plugin,
see L</"Disabling Tests">.

=item *

L<Dist::Zilla::Plugin::PodCoverageTests>, which checks that you have Pod
documentation for the things you should have it for. See L<Test::Pod::Coverage>
for what that means.

=item *

L<Dist::Zilla::Plugin::PodSyntaxTests>, which checks that your Pod is
well-formed. See L<Test::Pod> and L<perlpod> for details.

=item *

L<Dist::Zilla::Plugin::PortabilityTests>, which performs some basic tests to
ensure portability of file names. See L<Test::Portability::Files> for what
that means.

=item *

L<Dist::Zilla::Plugin::SynopsisTests>, which does syntax checking on the code
from your SYNOPSIS section. See L<Test::Synopsis> for details and limitations.

=item *

L<Dist::Zilla::Plugin::UnusedVarsTests>, which checks your dist for unused
variables. See L<Test::Vars> for details.

=item *

L<Dist::Zilla::Plugin::Test::CPAN::Changes>, which checks your changelog for
conformance with L<CPAN::Changes::Spec>. See L<Test::CPAN::Changes> for details.

Set C<changelog> in F<dist.ini> if you don't use F<Changes>:

    [@TestingMania]
    changelog = CHANGELOG

=back

=head2 Disabling Tests

To exclude a testing plugin, give a comma-separated list in F<dist.ini>:

    [@TestingMania]
    disable = EOLTests,NoTabsTests

=head2 Enabling Tests

This pluginbundle may have depend on some testing plugins that aren't
enabled by default. This option allows you to turn them on. Attempting to add
plugins which are not listed above will have I<no effect>.

To enable a testing plugin, give a comma-separated list in F<dist.ini>:

    [@TestingMania]
    enable = ConsistentVersionTest

=for Pod::Coverage configure

=for test_synopsis 1;
__END__

=head1 AVAILABILITY

The project homepage is L<http://p3rl.org/Dist::Zilla::PluginBundle::TestingMania>.

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<http://search.cpan.org/dist/Dist-Zilla-PluginBundle-TestingMania/>.

The development version lives at L<http://github.com/doherty/Dist-Zilla-PluginBundle-TestingMania>
and may be cloned from L<git://github.com/doherty/Dist-Zilla-PluginBundle-TestingMania.git>.
Instead of sending patches, please fork this project using the standard
git and github infrastructure.

=head1 SOURCE

The development version is on github at L<http://github.com/doherty/Dist-Zilla-PluginBundle-TestingMania>
and may be cloned from L<git://github.com/doherty/Dist-Zilla-PluginBundle-TestingMania.git>

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<https://github.com/doherty/Dist-Zilla-PluginBundle-TestingMania/issues>.

=head1 AUTHOR

Mike Doherty <doherty@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Mike Doherty.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

