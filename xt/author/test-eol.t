use strict;
use warnings;
use Test::More;
use Test::Requires qw( Test::EOL );

all_perl_files_ok({ trailing_whitespace => 1 });
