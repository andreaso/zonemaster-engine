use Test::More;

BEGIN {
    use_ok( q{Zonemaster::Engine} );
    use_ok( q{Zonemaster::Engine::Test::DNSSEC} );
    use_ok( q{Zonemaster::Engine::Util} );
}

my $datafile = q{t/Test-dnssec05-B.data};

if ( not $ENV{ZONEMASTER_RECORD} ) {
    die q{Stored data file missing} if not -r $datafile;
    Zonemaster::Engine::Nameserver->restore( $datafile );
    Zonemaster::Engine->profile->set( q{no_network}, 1 );
}

Zonemaster::Engine->add_fake_delegation(
    'b.dnssec05.exempelvis.se' => {
        'ns1.b.dnssec05.exempelvis.se' => ['46.21.97.97'],
        'ns2.b.dnssec05.exempelvis.se' => ['2a02:750:12:77::97'],
    }
);

my $zone = Zonemaster::Engine->zone( q{b.dnssec05.exempelvis.se} );

my %res = map { $_->tag => $_ } Zonemaster::Engine::Test::DNSSEC->dnssec05( $zone );

ok( !$res{NO_RESPONSE},             q{should not emit NO_RESPONSE} );
ok( $res{NO_RESPONSE_DNSKEY},       q{should emit NO_RESPONSE_DNSKEY} );
ok( !$res{ALGORITHM_DEPRECATED},    q{should not emit ALGORITHM_DEPRECATED} );
ok( !$res{ALGORITHM_RESERVED},      q{should not emit ALGORITHM_RESERVED} );
ok( !$res{ALGORITHM_UNASSIGNED},    q{should not emit ALGORITHM_UNASSIGNED} );
ok( !$res{ALGORITHM_PRIVATE},       q{should not emit ALGORITHM_PRIVATE} );
ok( !$res{ALGORITHM_NOT_ZONE_SIGN}, q{should not emit ALGORITHM_NOT_ZONE_SIGN} );
ok( !$res{ALGORITHM_DELETE_DS},     q{should not emit ALGORITHM_DELETE_DS} );
ok( !$res{ALGORITHM_INDIRECT_KEY},  q{should not emit ALGORITHM_INDIRECT_KEY} );
ok( !$res{ALGORITHM_OK},            q{should not emit ALGORITHM_OK} );

if ( $ENV{ZONEMASTER_RECORD} ) {
    Zonemaster::Engine::Nameserver->save( $datafile );
}

done_testing;
