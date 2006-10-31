#!perl

use strict;
use warnings;
use IO::File;
use Test::More;
use Audio::XMMSClient;

my $funcs = get_clientlib_functions('/usr/include/xmms2/xmmsclient/xmmsclient.h'); #TODO: be portable

if (!defined $funcs) {
    plan skip_all => 'Could not parse clientlib header';
    exit 0;
}

plan tests => scalar @{ $funcs };

for my $func (@{ $funcs }) {
    my ($class, $method) = class_and_method_from_func( $func );

    can_ok( $class, $method );
}

sub get_clientlib_functions {
    my ($header) = @_;

    my $fh = IO::File->new( $header, 'r' );
    return unless $fh;

    my @funcs;
    while (my $line = <$fh>) {
        next if $line !~ /^(?:xmmsc_connection_t|xmmsc_result_t|int|void|char|const char)/;

        my ($func_name) = $line =~ /(xmmsc_\w+)\s*\(/;
        next unless $func_name;

        push @funcs, $func_name
    }

    return \@funcs;
}

sub overrides {
    return {
        'Audio::XMMSClient' => {
            'init'                  => 'new',
            'unref'                 => undef, # pointless in perl
            'lock_set'              => undef, # TODO: support threading
            'entry_format'          => undef, # better done in perl because if the weird interface of entry_format
            'querygen_and'          => undef, # TODO: shall that be bound? Or write a nice bridge to DBI, i.e. DBD::XMMSClient?
            'sqlite_prepare_string' => undef, # TODO: ditto
        },
        'Audio::XMMSClient::Result' => {
            'run'                   => undef, # internal
            'ref'                   => undef, # pointless in perl
            'unref'                 => undef, # ditto
            'get_int'               => undef,
            'get_uint'              => undef,
            'get_string'            => undef,
            'get_bin'               => undef,
            'get_dict_entry_str'    => undef,
            'get_dict_entry_int32'  => undef,
            'get_dict_entry_uint32' => undef,
            'dict_foreach'          => undef,
            'propdict_foreach'      => undef,
            'is_list'               => undef,
            'list_next'             => undef,
            'list_first'            => undef,
            'list_valid'            => undef,
        },
    };
}

sub class_and_method_from_func {
    my ($func) = @_;

    my ($meth, $class);
    if (($meth) = $func =~ /^xmmsc_result_(.*)$/) {
        $class = 'Audio::XMMSClient::Result';
    }
    else {
        ($meth) = $func =~ /^xmmsc_(.*)$/;
        $class  = 'Audio::XMMSClient';
    }

    if (exists overrides()->{$class}->{$meth}) {
        my $override = overrides()->{$class}->{$meth};

        if (defined $override) {
            $meth = $override;
        }
        else {
            $meth = 'can'; # Always succeeds because of UNIVERSAL::can
        }
    }

    return ($class, $meth);
}
