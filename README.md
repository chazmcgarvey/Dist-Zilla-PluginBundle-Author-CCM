# NAME

Dist::Zilla::PluginBundle::Author::CCM - A plugin bundle for distributions built by CCM

# VERSION

version 0.012

# SYNOPSIS

    # In your dist.ini file:
    [@Author::CCM]

# DESCRIPTION

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

# ATTRIBUTES

## max\_target\_perl

Specify the minimum perl version. Defaults to `5.10.1`.

## no\_index

Set directories to not index.

Default:

## authority

Specify the release authority. Defaults to `cpan:CCM`.

## installer

Specify which installer to use, such as:

- `MakeMaker` (default)
- `MakeMaker::Custom`

## airplane

Disable plugins that use the network, and prevent releasing.

## no\_upload

Do not upload to CPAN or git push.

# METHODS

## configure

Required by [Dist::Zilla::Role::PluginBundle::Easy](https://metacpan.org/pod/Dist%3A%3AZilla%3A%3ARole%3A%3APluginBundle%3A%3AEasy).

# SEE ALSO

- [Dist::Zilla](https://metacpan.org/pod/Dist%3A%3AZilla)
- [Dist::Zilla::PluginBundle::Author::ETHER](https://metacpan.org/pod/Dist%3A%3AZilla%3A%3APluginBundle%3A%3AAuthor%3A%3AETHER)

# BUGS

Please report any bugs or feature requests on the bugtracker website
[https://github.com/chazmcgarvey/Dist-Zilla-PluginBundle-Author-CCM/issues](https://github.com/chazmcgarvey/Dist-Zilla-PluginBundle-Author-CCM/issues)

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHOR

Charles McGarvey <ccm@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Charles McGarvey.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
