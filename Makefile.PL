use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ZWON::Module::Starter',
    AUTHOR              => q{Pavel Shaydo <zwon@trinitum.org>},
    VERSION_FROM        => 'lib/ZWON/Module/Starter.pm',
    ABSTRACT_FROM       => 'lib/ZWON/Module/Starter.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ZWON-Module-Starter-*' },
);
