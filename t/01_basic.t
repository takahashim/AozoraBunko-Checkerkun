use strict;
use warnings;
use utf8;
use AozoraBunko::Tools::Checkerkun;
use Test::More;
use Test::Fatal;
binmode Test::More->builder->$_ => ':utf8' for qw/output failure_output todo_output/;

can_ok('AozoraBunko::Tools::Checkerkun', qw/new check/);

my %option = (
    'gaiji'            => 1, # JIS外字をチェックする
    'hansp'            => 1, # 半角スペースをチェックする
    'hanpar'           => 1, # 半角カッコをチェックする
    'zensp'            => 0, # 全角スペースをチェックする
    '78hosetsu_tekiyo' => 1, # 78互換包摂の対象となる不要な外字注記をチェックする
    'hosetsu_tekiyo'   => 1, # 包摂の対象となる不要な外字注記をチェックする
    '78'               => 0, # 78互換包摂29字をチェックする
    'jyogai'           => 0, # 新JIS漢字で包摂規準の適用除外となる104字をチェックする
    'gonin1'           => 0, # 誤認しやすい文字をチェックする(1)
    'gonin2'           => 0, # 誤認しやすい文字をチェックする(2)
    'gonin3'           => 0, # 誤認しやすい文字をチェックする(3)
    'simplesp'         => 0, # 半角スペースは「_」で、全角スペースは「□」で出力する
);

subtest 'new method' => sub {
    my $exception;

    $exception = exception { AozoraBunko::Tools::Checkerkun->new; };
    is($exception, undef, 'default options');

    $exception = exception { AozoraBunko::Tools::Checkerkun->new(%option) };
    is($exception, undef, 'valid options hash');

    $exception = exception { AozoraBunko::Tools::Checkerkun->new(\%option) };
    is($exception, undef, 'valid options hashref');

    my %invalid_option = %option;
    $invalid_option{'hogehoge'} = 0;

    $exception = exception { AozoraBunko::Tools::Checkerkun->new(%invalid_option) };
    like($exception, qr/Unknown option: 'hogehoge'/, 'invalid option hash');

    $exception = exception { AozoraBunko::Tools::Checkerkun->new(\%invalid_option) };
    like($exception, qr/Unknown option: 'hogehoge'/, 'invalid option hashref');
};

subtest 'check method' => sub {
    my $checker = AozoraBunko::Tools::Checkerkun->new;
    ok($checker->check('ほげほげ'), 'check method ok');

    $checker = AozoraBunko::Tools::Checkerkun->new;
    is($checker->check(''), '', 'empty string');

    $checker = AozoraBunko::Tools::Checkerkun->new;
    is($checker->check(undef), undef, 'undef');
};

done_testing;
