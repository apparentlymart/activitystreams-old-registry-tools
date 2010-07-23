
=head1 NAME

ASRegistry - Libraries for parsing and wrangling the Activity Streams registry

=cut

package ASRegistry;

use strict;
use warnings;

use YAML::Syck qw();
use Data::Dumper;

use ASRegistry::Spec;

sub from_source_dir {
    my ($class, $source_dir) = @_;

    my $self = bless {}, $class;
    my $specs = $self->{specs} = [];
    my $all_verbs = $self->{all_verbs} = {};

    my @files = glob "$source_dir/*.yaml";

    foreach my $filename (@files) {
        my $dict = YAML::Syck::LoadFile($filename);
        my $spec = ASRegistry::Spec->from_dict($dict);
        push @$specs, $spec;

        foreach my $verb (@{$spec->verbs}) {
            my $identifier = $verb->identifier;
            my $list = $all_verbs->{$identifier} ||= [];
            push @$list, $verb;
        }
    }

    return $self;
}

sub specs {
    return $_[0]->{specs};
}

1;
