#!/usr/bin/perl
use 5.010;
use strict;
use warnings;

use ZWON::Module::Starter;
use Getopt::Long;
use Log::Log4perl qw(:easy get_logger);

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
    "github=s" => \my $github,
    help            => \my $help,
    "quiet"         => \my $quiet,
) or die $usage;

die $usage if $help;
die $usage unless $author && $email && $distr;
Log::Log4perl->easy_init($DEBUG) unless $quiet;

get_logger->info( "Creating $distr using author $author <$email>");

my $starter = ZWON::Module::Starter->new( author => $author, email => $email, dist_name => $distr, github => $github );
$starter->process_templates;

chdir $started->dist_dir_name or die $!;
system(qw(git init));
system(qw(git add .));
system($^X, "Makefile.PL");
system(qw(make manifest));
system(qw(git add MANIFEST));
system('git', 'ci', '-m', "module skeleton");

