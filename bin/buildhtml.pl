#!/usr/bin/perl

=head1 NAME

buildhtml - parses a directory of registry JSON files and produces HTML pages describing the contents.

=head1 SYNOPSIS

    buildhtml <source directory> <target directory>

=cut

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Pod::Usage;
use Template;
use Data::Dumper;
use File::Path;

use ASRegistry;

my $tt = Template->new({
    INCLUDE_PATH => "$FindBin::Bin/../templates",
});

my $source_dir = shift or pod2usage("Source directory is required");
my $target_dir = shift or pod2usage("Target directory is required");

my $registry = ASRegistry->from_source_dir($source_dir);

# Specs index page
{
    my $vars = {};
    my $draft_specs = $vars->{specs}{draft} = [];
    my $published_specs = $vars->{specs}{published} = [];

    foreach my $spec (@{$registry->specs}) {
        if ($spec->is_draft) {
            push @$draft_specs, spec_summary_for_template($spec);
        }
        else {
            push @$published_specs, spec_summary_for_template($spec);
        }
    }

    build_page('specs', 'specs.tt', $vars);
}

# Individual Spec index pages and their child
# description pages.
{
    foreach my $spec (@{$registry->specs}) {
        my $vars = {};
        $vars->{spec} = spec_summary_for_template($spec);

        my $verbs = $vars->{verbs} = [];
        foreach my $verb (sort { $a->name cmp $b->name } @{$spec->verbs}) {
            push @$verbs, verb_summary_for_template($verb);
        }

        my $fn = "specs/".$spec->identifier;
        build_page($fn, 'spec.tt', $vars);
    }
}

sub spec_summary_for_template {
    my ($spec) = @_;

    my $ret = {};
    $ret->{title} = $spec->title;
    $ret->{identifier} = $spec->identifier;
    $ret->{index_url} = "specs/".$spec->identifier."/";
    $ret->{is_draft} = $spec->is_draft;
    return $ret;
}

sub verb_summary_for_template {
    my ($verb) = @_;

    my $spec = $verb->spec;

    my $ret = {};
    $ret->{name} = $verb->name;
    $ret->{identifier} = $verb->identifier;
    $ret->{index_url} = "specs/".$spec->identifier."/verbs/".$verb->identifier."/";
    $ret->{is_draft} = $verb->is_draft;
    $ret->{description} = $verb->description;
    return $ret;
}

sub build_page {
    my ($page_fn, $template, $vars) = @_;

    my $real_fn = "$target_dir/$page_fn/index.html";
    my $dir_name = $real_fn;
    $dir_name =~ s!/[^/]+$!!;
    File::Path::mkpath($dir_name);
    $tt->process($template, $vars, $real_fn) || die $tt->error(), "\n";
}

