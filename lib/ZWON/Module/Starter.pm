package ZWON::Module::Starter;

use 5.010;
use Moose;
use Template;
use POSIX qw(strftime);
use Path::Class;
use Log::Log4perl qw(get_logger :nowarn);

=head1 NAME

ZWON::Module::Starter - Create distribution skeleton as ZWON likes

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

Use L<new-module.pl>

=head1 SUBROUTINES

=cut

has author     => ( is => 'ro', required   => 1 );
has email      => ( is => 'ro', required   => 1 );
has email_safe => ( is => 'ro', lazy_build => 1 );
has github_account  => ( is => 'ro' );

sub _build_email_safe {
    my $email = shift->email;
    $email =~ s/\@/ at /;
    return $email;
}
has dist_name => ( is => 'ro', required   => 1 );
has dist_path => ( is => 'ro', lazy_build => 1 );

sub _build_dist_path {
    my $self = shift;
    return file( split /::/, $self->dist_name . ".pm" );
}
has dist_dir_name => ( is => 'ro', lazy_build => 1 );

sub _build_dist_dir_name {
    my $name = shift->dist_name;
    $name =~ s/::/-/g;
    return $name;
}

has date => ( is => 'ro', default => sub { strftime "%a %b %d %Y", localtime } );
has year => ( is => 'ro', default => sub { (localtime)[5] + 1900 } );

has file_maps => ( is => 'ro', lazy_build => 1 );

sub _build_file_maps {
    my $self = shift;
    my %map  = (
        Changes        => 'Changes',
        gitignore      => '.gitignore',
        Makefile       => 'Makefile.PL',
        README         => 'README.pod',
        t_00_load      => 't/00-load.t',
        t_pod          => 'xt/pod.t',
        t_pod_coverage => 'xt/pod-coverage.t',
        t_pod_spell    => 'xt/pod-spell.t',
        t_manifest     => 'xt/manifest.t',
    );
    $map{Module} = file( 'lib', $self->dist_path );
    return \%map;
}

=head2 $self->process_templates

Generate module skeleton from templates

=cut

sub process_templates {
    my $self = shift;
    my $tdir;

    for (@INC) {
        my $dir = dir( $_, split( /::/, __PACKAGE__ ), 'Templates' );
        next unless -d $dir;
        $tdir = $dir;
    }
    die "Couldn't find templates in ", join ", ", @INC unless $tdir;
    get_logger->debug("found templates in $tdir");

    my $tt = Template->new( INCLUDE_PATH => $tdir, );
    while ( my ( $key, $value ) = each %{ $self->file_maps } ) {
        my $file  = file($self->dist_dir_name, $value);
        my $fdir  = $file->dir;
        unless ( -d $fdir ) {
            get_logger->info("Creating $fdir");
            $fdir->mkpath( 0, 0755 );
        }
        get_logger->info("Writing $file");
        $tt->process( "$key.tt", { st => $self }, "$file" ) || die $tt->error;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Pavel Shaydo, C<< <zwon at trinitum.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Pavel Shaydo.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
