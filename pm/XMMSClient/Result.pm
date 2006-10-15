package Audio::XMMSClient::Result;

use strict;
use warnings;

sub format {
    my ($self, $format) = @_;

    $format =~ s/
            \$\{
                ([^}]+)
            \}
        /
            $self->value->{lc $1}
        /igxe;

    return $format;
}

1;
