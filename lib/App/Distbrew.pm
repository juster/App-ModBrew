package App::Distbrew;

use warnings;
use strict;

use Pod::Usage qw(pod2usage);
use Pod::Find;

my @_OPTS_SPEC;

# We act as both a factory and a base-class.
sub new
{
    my $class = shift;
    my @args  = @_;

    # Perform like a base class...
    return bless { args => [ @args ] }, $class
        unless $class eq __PACKAGE__;

    # Perform as a factory, create the proper sub-class...
    print_help() unless @args;

    my $cmd_arg   = lc shift @args;
    my ($command) = grep { $_ eq $cmd_arg }
        qw/ install add rem list check help /;

    die qq{ERROR: Unknown command "$cmd_arg".  See the "help" command.\n}
        unless $command;

    # A special case is if the command is help.
    print_help( shift @args ) if $command eq 'help';

    my $cmdclass = _cmd_class( $command );
    eval { require $cmdclass }
        or die q{ERROR: Failed to load distbrew command class } .
              qq{"$cmdclass"\n$@};
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
    my $podpath   = Pod::Find::pod_where( { -inc => 1 }, $package )
        or die qq{ERROR Failed to find docs for the "$command" command};

    # Copied from Pod::Usage manpage...
    require Pod::Find;
    pod2usage( -input => );
    exit 0;
}

1;

__END__

=head1 NAME

distbrew - Link your projects into your local perl libraries.

=head1 SYNOPSIS

distbrew [command] [command-args]

  Commands:
    install     Installs distbrew into ~/perl5/distbrew.
    add         Links a project directory to your ~/perl5.
    rem[ove]    Removes a project's links from your ~/perl5.
    list        List which project directories are linked into ~/perl5.
    check       Rebuild your projects and update your links if you need.
    help [cmd]  Display this help or help on a specific command.

=head1 DESCRIPTION

This script adds symbolic links from your own perl projects to your
locally installed perl modules under ~/perl5.

=head1 AUTHOR

Justin Davis C<< <juster at cpan dot dot dot> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Justin Davis, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
