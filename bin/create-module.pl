#!/usr/bin/perl
use 5.010;
use strict;
use warnings;

use ZWON::Module::Starter;
use Getopt::Long;
use Log::Log4perl qw(:easy get_logger);
use Pod::Text;

my $usage = <<EOT;
create-module.pl [OPTIONS]

--author    author name
--email     author e-mail
--github    github account
--distribution  distribution name
EOT

my ( $author, $email );
if ( $ENV{EMAIL} ) {
    ( $author, $email ) = $ENV{EMAIL} =~ /^(.+)\s[<]([^>]+)[>]/;
}

GetOptions(
    "author=s"       => \$author,
    "email=s"        => \$email,
    "distribution=s" => \my $distr,
    "github=s"       => \my $github,
    "copyright=s"    => \my $copyright,
    help             => \my $help,
    "quiet"          => \my $quiet,
) or die $usage;

die $usage if $help;
die $usage unless $author && $email && $distr;
Log::Log4perl->easy_init($DEBUG) unless $quiet;

get_logger->info("Creating $distr using author $author <$email>");

my $starter = ZWON::Module::Starter->new(
    author         => $author,
    email          => $email,
    dist_name      => $distr,
    github_account => $github,
    copyright      => $copyright,
);
$starter->process_templates;

chdir $starter->dist_dir_name or die $!;
my $parser = Pod::Text->new;
$parser->parse_from_file( 'README.pod', 'README' );
system(qw(git init));
system(qw(git add .));
system( $^X, "Makefile.PL" );
system(qw(make manifest));
system(qw(git add MANIFEST));
system( 'git', 'ci', '-m', "module skeleton" );

if ($github) {
    system( qw(git remote add origin), "git\@github.com:$github/perl-" . $starter->dist_dir_name );
    get_logger->warn( "Added Github repository perl-"
          . $starter->dist_dir_name . " as origin.");
    get_logger->warn("You should manually create this repository before you can push" );
}

