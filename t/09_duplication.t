use strict;
use warnings;
use utf8;
use AozoraBunko::Tools::Checkerkun;
use Test::More;
binmode Test::More->builder->$_ => ':utf8' for qw/output failure_output todo_output/;

my @key_list = (
    keys %{$AozoraBunko::Tools::Checkerkun::JYOGAI}
  , keys %{$AozoraBunko::Tools::Checkerkun::J78}
  , keys %{$AozoraBunko::Tools::Checkerkun::GONIN1}
  , keys %{$AozoraBunko::Tools::Checkerkun::GONIN2}
  , keys %{$AozoraBunko::Tools::Checkerkun::GONIN3}
#  , keys %{$AozoraBunko::Tools::Checkerkun::KYUJI}
#  , keys %{$AozoraBunko::Tools::Checkerkun::ITAIJI}
);

my %cnt;
$cnt{$_}++ for @key_list;

my @duplicate_chars = grep { $cnt{$_} > 1 } keys %cnt;

is(scalar @duplicate_chars, 0, 'duplication') or diag("duplicate chars: @duplicate_chars");

done_testing;
