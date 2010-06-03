package App::ModBrew::Install;

use warnings;
use strict;

use App::ModBrew qw();
use File::Path   qw(mkpath);
use File::Copy   qw(copy);

our @ISA = qw(App::ModBrew);

sub new
{
    my $class = shift;

    my $self = $class->SUPER::new( @_ );
    return $self;
}

sub run
{
    my ($self) = @_;
    $self->create_modbrew_dirs();
    $self->clone_modbrew();

    return 0;
}

sub create_modbrew_dirs
{
    my ($self) = @_;
    my $prefix = $self->{'prefix'};

    MKDIR_LOOP:
    for my $dir ( map { $self->_modbrew_path( $_ ) }
                  qw{ bin lib etc } ) {
        if ( -d $dir ) {
            warn "Directory $dir already exists, skipping.\n";
            next MKDIR_LOOP;
        }
        mkpath( $dir, 0, 0755 );
    }

    $self->touch_sources();

    return;
}

sub touch_sources
{
    my ($self) = @_;

    my $src_path = $self->_modbrew_path( 'etc/sources' );
    return if -f $src_path;

    open my $sources_fh, '>', $src_path or die "open: $!";
    close $sources_fh or die "close: $!";

    return;
}

sub clone_modbrew
{
    my ($self) = @_;

    my $dest_fqp = $self->_modbrew_path( 'bin/modbrew' );
    copy $0, $dest_fqp or die "failed to copy ourself to $dest_fqp: $!";

    return;
}

1;

__END__

=head1 NAME

modbrew install - Installs modbrew under your home directory.

=head1 SYNOPSIS

modbrew install

The install command copies the script (that is running) to
C<~/perl5/modbrew>.  Modbrew sets up an empty sources list file and
the directory structure.

Use the MODBREW_PREFIX environment variable to override the prefix
that is used.

=head1 AUTHOR

Justin Davis C<< <juster at cpan dot dot dot> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Justin Davis, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
