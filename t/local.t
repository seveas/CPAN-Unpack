use strict;
use warnings;
use File::Path;
use Test::More tests => 14;
use_ok("CPAN::Unpack");

rmtree("t/unpacked");
rmtree("t/unpacked2");

ok( !-d "t/unpacked", "No t/unpacked at the start" );
ok( !-d "t/unpacked2", "No t/unpacked at the start" );

my $u = CPAN::Unpack->new;
$u->cpan("t/cpan/");
$u->destination("t/unpacked/");
$u->unpack;

ok( -d "t/unpacked" );
ok( -d "t/unpacked/Acme-Buffy" );
ok( -d "t/unpacked/Acme-Colour" );
ok( -d "t/unpacked/GraphViz" );

my @files = <t/unpacked/GraphViz/*>;
is( scalar(@files), 7 );

$u = CPAN::Unpack->new;
$u->cpan("t/cpan/");
$u->destination("t/unpacked2/");
$u->all_versions(1);
$u->unpack;

ok( -d "t/unpacked2" );
ok( -d "t/unpacked2/Acme-Buffy-1.3" );
ok( -d "t/unpacked2/Acme-Buffy-1.4" );
ok( -d "t/unpacked2/Acme-Colour-1.01" );
ok( -d "t/unpacked2/GraphViz-1.8" );

@files = <t/unpacked2/GraphViz-1.8/*>;
is( scalar(@files), 7 );
