package Dist::Zilla::PluginBundle::Author::CCM;
# ABSTRACT: A plugin bundle for distributions built by CCM
# KEYWORDS: dzil author bundle distribution tool

=head1 SYNOPSIS

    # In your dist.ini file:
    [@Author::CCM]

=head1 DESCRIPTION

You probably don't want to use this.

    ; VERSION
    [Git::NextVersion]

    ; GATHER
    [Git::GatherDir]
    exclude_filename    = LICENSE
    exclude_filename    = README.md
    [PruneCruft]
    [PruneFiles]
    filename            = dist.ini

    [CopyFilesFromBuild]
    copy                = LICENSE
    [ExecDir]

    ; PREREQS
    [AutoPrereqs]
    [Prereqs::FromCPANfile]     ; if a cpanfile exists in root
    [Prereqs::AuthorDeps]

    ; TESTS
    [MetaTests]
    [Test::CPAN::Changes]
    [PodCoverageTests]
    [PodSyntaxTests]
    [Test::Pod::No404s]
    [Test::Compile]
    [Test::MinimumVersion]
    max_target_perl     = 5.10.1
    [Test::EOL]
    [Test::NoTabs]
    [Test::Perl::Critic]
    [Test::Portability]
    [Test::CleanNamespaces]
    [Test::ReportPrereqs]

    ; METADATA
    [Authority]
    do_munging          = 0
    [MetaJSON]
    [MetaYAML]
    [MetaNoIndex]
    directory           = eg
    directory           = share
    directory           = shares
    directory           = t
    directory           = xt
    [MetaProvides::Package]
    [Keywords]
    [Git::Contributors]
    order_by            = commits
    [GithubMeta]
    issues              = 1

    ; MUNGE
    [PodWeaver]
    config_plugin       = @Author::CCM
    [OverridePkgVersion]

    ; GENERATE FILES
    [License]
    [ReadmeAnyFromPod]
    filename            = README.md
    locaton             = root
    type                = markdown
    phase               = release
    [ReadmeAnyFromPod]
    filename            = README
    location            = build
    type                = text
    [Manifest]
    [ManifestSkip]

    [MakeMaker]                 ; override with the "installer" attribute

    ; RELEASE
    [NextRelease]
    [CheckChangesHasContent]
    [Git::Check]
    [RunExtraTests]
    [TestRelease]
    [ConfirmRelease]
    [UploadToCPAN]              ; disable with the "no_upload" attribute
    [Git::Commit]
    commit_msg          = Release %N %v%t%n%n%c
    [Git::CommitBuild]
    branch              =
    release_branch      = dist
    release_message     = Version %v%t
    [Git::Tag]
    tag_message         = Version %v%t%n%n%c
    [Git::Push]
    push_to             = origin master +master:refs/heads/release +dist
    remotes_must_exist  = 0

=head1 SEE ALSO

=for :list
* L<Dist::Zilla>
* L<Dist::Zilla::PluginBundle::Author::ETHER>

=cut

use 5.014;
use warnings;
use strict;

our $VERSION = '999.999'; # VERSION

use Dist::Zilla::Util;
use Moose;
use Perl::Version;
use namespace::autoclean;

=attr max_target_perl

Specify the minimum perl version. Defaults to C<5.10.1>.

=cut

has max_target_perl => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->payload->{'Test::MinimumVersion.max_target_perl'}
            // $self->payload->{max_target_perl}
            // '5.10.1';
    },
);

=attr no_index

Set directories to not index.

Default:

=cut

has no_index => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        [split(/\s+/, $self->payload->{'MetaNoIndex.directories'}
                     // $self->payload->{no_index}
                     // 'eg share shares t xt')];
    },
);

=attr authority

Specify the release authority. Defaults to C<cpan:CCM>.

=cut

has authority => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->payload->{'Authority.authority'} // $self->payload->{authority} // 'cpan:CCM';
    },
);

=attr installer

Specify which installer to use, such as:

=for :list
* C<MakeMaker> (default)
* C<MakeMaker::Custom>

=cut

has installer => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->payload->{installer} // 'MakeMaker' },
);

=attr airplane

Disable plugins that use the network, and prevent releasing.

=cut

has airplane => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $ENV{DZIL_AIRPLANE} // shift->payload->{airplane} // 0 },
);

=attr no_upload

Do not upload to CPAN or git push.

=cut

has no_upload => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $ENV{DZIL_NO_UPLOAD} // shift->payload->{no_upload} // 0 },
);

=method configure

Required by L<Dist::Zilla::Role::PluginBundle::Easy>.

=cut

sub configure {
    my $self = shift;

    my @copy_from_build     = qw(LICENSE);
    my @network_plugins     = qw(Git::Push Test::Pod::No404s UploadToCPAN);
    my @gather_exclude      = (@copy_from_build, qw(README.md));
    my @gather_prune        = qw(dist.ini);
    my @no_index            = @{$self->no_index};
    my @allow_dirty         = (@copy_from_build, qw(Changes LICENSE README.md));
    my @git_remotes         = qw(github origin);
    my @check_files         = qw(:InstallModules :ExecFiles :TestFiles :ExtraTestFiles);
    my $perl_version_target = $self->max_target_perl;
    my $installer           = $self->installer;

    if ($self->no_upload) {
        say '[@Author::CCM] WARNING! WARNING! WARNING! *** You are in no_upload mode!! ***';
    }

    my @plugins = (

        # VERSION
        ['Git::NextVersion'],

        # GATHER
        ['Git::GatherDir' => {exclude_filename  => [@gather_exclude]}],
        ['PruneCruft'],
        ['PruneFiles' => {filename => [@gather_prune]}],

        ['CopyFilesFromBuild' => {copy => [@copy_from_build]}],
        ['ExecDir'],

        # PREREQS
        ['AutoPrereqs'],
        -f 'cpanfile' ? ['Prereqs::FromCPANfile'] : (),
        ['Prereqs::AuthorDeps'],

        # TESTS
        ['MetaTests'],
        ['Test::CPAN::Changes'],
        ['PodCoverageTests'],
        ['PodSyntaxTests'],
        ['Test::Pod::No404s'],
        ['Test::Compile'],
        ['Test::MinimumVersion' => {max_target_perl => $perl_version_target}],
        ['Test::EOL' => {finder => [@check_files]}],
        ['Test::NoTabs' => {finder => [@check_files]}],
        ['Test::Perl::Critic'],
        ['Test::Portability'],
        ['Test::CleanNamespaces'],
        ['Test::ReportPrereqs'],

        # METADATA
        ['Authority' => {authority => $self->authority, do_munging => 0}],
        ['MetaJSON'],
        ['MetaYAML'],
        ['MetaNoIndex' => {directory => [@no_index]}],
        ['MetaProvides::Package'],
        ['Keywords'],
        ['Git::Contributors' => {order_by => 'commits'}],
        ['GithubMeta' => {remote => [@git_remotes], issues => 1}],

        # MUNGE
        ['PodWeaver' => {config_plugin => '@Author::CCM'}],
        ['OverridePkgVersion'],

        # GENERATE FILES
        ['License'],
        ['ReadmeAnyFromPod' => 'RepoReadme' => {filename => 'README.md', location => 'root', type => 'markdown', phase => 'release'}],
        ['ReadmeAnyFromPod' => 'DistReadme' => {filename => 'README', location => 'build', type => 'text'}],
        ['Manifest'],
        ['ManifestSkip'],

        $installer ? $self->installer : (), # e.g. MakeMaker

        # RELEASE
        ['NextRelease' => {format => '%-9v %{yyyy-MM-dd HH:mm:ssZZZ}d%{ (TRIAL RELEASE)}T'}],
        ['CheckChangesHasContent'],
        ['Git::Check' => {allow_dirty => [@allow_dirty], untracked_files => 'ignore'}],
        ['RunExtraTests'],
        ['TestRelease'],
        # ['ConfirmRelease'],
        $self->no_upload ? ['FakeRelease'] : ['UploadToCPAN'],
        ['Git::Commit' => {allow_dirty => [@allow_dirty], commit_msg => 'Release %N %v%t%n%n%c'}],
        ['Git::CommitBuild' => {branch => '', release_branch => 'dist', release_message => 'Version %v%t'}],
        ['Git::Tag' => {tag_message => 'Version %v%t%n%n%c'}],
        $self->no_upload ? () : ['Git::Push' => {push_to => 'origin master +master:refs/heads/release +dist', remotes_must_exist => 0}],

    );

    if ($self->airplane) {
        my %network_plugins = map { Dist::Zilla::Util->expand_config_package_name($_) => 1 } @network_plugins;

        @plugins = grep { !$network_plugins{Dist::Zilla::Util->expand_config_package_name(ref eq 'ARRAY' ? $_->[0] : $_)} } @plugins;
        push @plugins, 'BlockRelease';
    }

    push @plugins, 'ConfirmRelease';

    $self->add_plugins(@plugins);
}

with 'Dist::Zilla::Role::PluginBundle::Easy';
with 'Dist::Zilla::Role::PluginBundle::PluginRemover';
with 'Dist::Zilla::Role::PluginBundle::Config::Slicer';

__PACKAGE__->meta->make_immutable;
1;
