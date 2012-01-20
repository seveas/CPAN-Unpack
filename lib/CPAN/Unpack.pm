package CPAN::Unpack;
use strict;
use warnings;
use Archive::Extract;
use File::Path;
use Parse::CPAN::Packages;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(cpan destination));
$Archive::Extract::PREFER_BIN = 1;

our $VERSION = '0.23';

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  return $self;
}

sub unpack {
  my $self = shift;

  my $cpan = $self->cpan;
  die "No $cpan" unless -d $cpan;

  my $destination = $self->destination;
  mkdir $destination;
  die "No $destination" unless -d $destination;

  my $packages_filename = "$cpan/modules/02packages.details.txt.gz";
  die "No packages at $packages_filename" unless -f $packages_filename;

  my $p = Parse::CPAN::Packages->new($packages_filename);
  foreach my $distribution ($p->latest_distributions) {
    print "About to do " . $distribution->prefix . "\n";
    my $want = "$destination/" . $distribution->dist;
    next if -d $want;

    my $archive_filename = "$cpan/authors/id/" . $distribution->prefix;

    unless (-f $archive_filename) {
	warn "No $archive_filename";
	next;
    }

    my $extract = Archive::Extract->new(archive => $archive_filename);
    my $to = "$destination/test";
    rmtree($to);
    mkdir($to);
    $extract->extract(to => $to);
    my @files = <$to/*>;
    my $files = @files;
    if ($files == 1) {
      my $file = $files[0];
      rename $file, $want;
      rmdir $to;
    } else {
      rename $to, $want;
    }
  }
}

__END__

=head1 NAME

CPAN::Unpack - Unpack CPAN distributions

=head1 SYNOPSIS

  use CPAN::Unpack;
  my $u = CPAN::Unpack->new;
  $u->cpan("path/to/CPAN/");
  $u->destination("cpan_unpacked/");
  $u->unpack;

=head1 DESCRIPTION

The Comprehensive Perl Archive Network (CPAN) is a very useful
collection of Perl code. It has a whole lot of module
distributions. This module unpacks the latest version of each
distribution. It places it in a directory of your choice with
directories being the name of the distribution.

It requires a local CPAN mirror to run. You can construct one using
something similar to:

  /usr/bin/rsync -av --delete ftp.nic.funet.fi::CPAN /Users/acme/cpan/CPAN/

Note that a CPAN mirror can take up about 1.5G of space (and will take
a while to rsync initially). Additionally, unpacking will use up about
another 1.6G.

This can be handy for code metrics, searching CPAN, or just being very
nosy indeed.

This uses Parse::CPAN::Packages' latest_distributions method for
finding the latest distribution.

=head1 AUTHOR

Leon Brocard <acme@astray.com>

=head1 COPYRIGHT

Copyright (C) 2004-8, Leon Brocard

=head1 LICENSE

This module is free software; you can redistribute it or modify it under
the same terms as Perl itself.
