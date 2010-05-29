package App::ModBrew;

use File::Find qw();

use warnings;
use strict;
our $VERSION = '0.01';

my $DEFAULT_MODBREW_PREFIX = '~/perl5/modbrew';

my @_OPTS_SPEC;

# We act as both a factory and a base-class.
sub new
{
    my $class = shift;
    my @args  = @_;

    # Perform like a base class...
    return bless { args   => [ @args ],
                   prefix => $ENV{MODBREW_PREFIX} || $DEFAULT_MODBREW_PREFIX,
                  }, $class unless $class eq __PACKAGE__;

    # Perform as a factory, create the proper sub-class...
    print_help() unless @args;

    my $cmd_arg   = lc shift @args;
    $cmd_arg      =~ s/\Arm\z/remove/;
    my ($command) = grep { $_ eq $cmd_arg }
        qw/ install add remove list check help /;

    die qq{ERROR: Unknown command "$cmd_arg".  See the "help" command.\n}
        unless $command;

    # A special case is if the command is help.
    print_help( shift @args ) if $command eq 'help';

    my $cmdclass = _cmd_class( $command );
    eval { require $cmdclass }
        or die qq{ERROR: Failed to load class for "$command" command\n$@};
    return $cmdclass->new( @args );
}

sub _cmd_class
{
    my $command = shift;
    return sprintf '%s::%s', __PACKAGE__, ucfirst $command;
}

# Each command/module has its own help docs as POD...
sub print_help
{
    my ($command) = @_;
    my $package   = ( $command ? _cmd_class( $command ) : __PACKAGE__ );

    # Copied from Pod::Usage manpage...
    require Pod::Usage;
    require Pod::Find;
    my $podpath = Pod::Find::pod_where( { -inc => 1 }, $package )
        or die qq{ERROR: Failed to find docs for the "$command" command};
    Pod::Usage::pod2usage( -input => $podpath );
    exit 0;
}

#---HELPER METHOD---
sub _map_linkables
{
    my ($self, $search_dir, $dest_prefix) = @_;

    my %link_dest_of;

    my $add_link = sub {
        my ($src_abs) = @_;
        my $dest =~ s/\A$search_dir//;
        $dest = File::Spec->catpath( $dest_prefix, $dest );
        $link_dest_of{ $src_abs } = $dest;
    };

    my $finder = sub {
        return unless ( /[.]pm\z/ || -x $_ );
        $add_link->( $File::Find::name );
    };

    return %link_dest_of;
}

#---HELPER METHOD---
sub _load_source_list
{
    my ($self) = @_;

    my $listpath = File::Spec->catfile( $self->{'prefix'},
                                        qw/ etc sources / );
    return qw// unless -f $listpath;
    open my $listfile, '<', $listpath or die "open $listpath failed: $!";

    my @source_list = grep { length } map { chomp } <$listfile>;
    close $listfile;

    return @source_list;
}

#---HELPER METHOD---
sub _save_source_list
{
    my ($self, @sources) = @_;

    my $listpath = File::Spec->catfile( $self->{'prefix'},
                                        qw/ etc sources / );
    open my $listfile, '>', $listpath or die "open $listpath failed: $!";
    print $listfile "$_\n" for @sources;
    close $listfile;

    return;
}

1;

__END__

=head1 NAME

modbrew - Turn on or off locally installed perl modules.

=head1 SYNOPSIS

modbrew [command] [command-args]

  Commands:
    install     Installs modbrew (default: ~/perl5/modbrew).
    update      Try to update ourselves (requires git).
    add         Add a directory to link into your modbrew dir.
    rm/remove   Removes a directory's links from your modbrew dir.
    list        List which directories are linked into ~/perl5/modbrew.
    check       Checks our links.
    help [cmd]  Display this help or help on a specific command.

=head1 DESCRIPTION

This script adds symbolic links from your own perl projects to your
locally installed perl modules under ~/perl5.

=head1 SEE ALSO

=over 4

=item * L<App::perlbrew>

=item * homebrew

=back

=head1 AUTHOR

Justin Davis C<< <juster at cpan dot dot dot> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Justin Davis, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
