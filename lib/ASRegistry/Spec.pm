
=head1 NAME

ASRegistry::Spec - Represents the definition of a specification in the registry.

=cut

package ASRegistry::Spec;

use strict;
use warnings;

use ASRegistry::Verb;

sub from_dict {
    my ($class, $dict) = @_;

    my $self = bless {}, $class;

    $self->{identifier} = $dict->{identifier};
    $self->{title} = $dict->{title};
    $self->{specification_url} = $dict->{specification_url};
    $self->{status} = $dict->{status} || 'published';

    my $verbs = $self->{verbs} = [];
    if (my $verb_dicts = $dict->{verbs}) {
        foreach my $dict (@$verb_dicts) {
            push @$verbs, ASRegistry::Verb->from_dict($dict, $self);
        }
    }

    return $self;
}

sub identifier {
    return $_[0]->{identifier};
}

sub title {
    return $_[0]->{title};
}

sub spec_url {
    return $_[0]->{specification_url};
}

sub status {
    return $_[0]->{status};
}

sub is_draft {
    return $_[0]->{status} eq 'draft' ? 1 : 0;
}

sub verbs {
    return $_[0]->{verbs};
}

1;
