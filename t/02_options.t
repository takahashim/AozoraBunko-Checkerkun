use strict;
use warnings;
use utf8;
use AozoraBunko::Tools::Checkerkun;
use Test::More;
binmode Test::More->builder->$_ => ':utf8' for qw/output failure_output todo_output/;

my %option = (
    'gaiji'            => 0, # JIS外字をチェックする
    'hansp'            => 0, # 半角スペースをチェックする
    'hanpar'           => 0, # 半角カッコをチェックする
    'zensp'            => 0, # 全角スペースをチェックする
    '78hosetsu_tekiyo' => 0, # 78互換包摂の対象となる不要な外字注記をチェックする
    'hosetsu_tekiyo'   => 0, # 包摂の対象となる不要な外字注記をチェックする
    '78'               => 0, # 78互換包摂29字をチェックする
    'jyogai'           => 0, # 新JIS漢字で包摂規準の適用除外となる104字をチェックする
    'gonin1'           => 0, # 誤認しやすい文字をチェックする(1)
    'gonin2'           => 0, # 誤認しやすい文字をチェックする(2)
    'gonin3'           => 0, # 誤認しやすい文字をチェックする(3)
    'simplesp'         => 0, # 半角スペースは「_」で、全角スペースは「□」で出力する
    'output_format'    => 'plaintext', # 'plaintext' または 'html'
);

subtest 'no options' => sub {
    my $text = "\x{0000}\r\nｴ AB　Ｃ" x 2;
    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%option);
    is($checker1->check($text), "\x{0000} [ctrl]【U+0000】 \r\nｴ [hankata]【ｴ】  AB　Ｃ" x 2);
};

subtest 'gaiji' => sub {
    my %opts = %option;

    my $text = '森鷗外' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'gaiji'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '森鷗 [gaiji]【鷗】 外' x 2);
};

subtest 'hansp' => sub {
    my %opts = %option;

    my $text = '太宰 治' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'hansp'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '太宰  [hansp]【 】 治' x 2);
};

subtest 'hanpar' => sub {
    my %opts = %option;

    my $text = '太)宰治(' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'hanpar'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '太) [hanpar]【)】 宰治( [hanpar]【(】 ' x 2);
};

subtest 'zensp' => sub {
    my %opts = %option;

    my $text = '太宰　治' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'zensp'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '太宰　 [zensp]【　】 治' x 2);
};

subtest '78hosetsu_tekiyo' => sub {
    my %opts = %option;

    my $text = '※［＃「區＋鳥」、第3水準1-94-69］外' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'78hosetsu_tekiyo'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '※［＃「區＋鳥」、第3水準1-94-69］ → [78hosetsu_tekiyo]【鴎】 外' x 2);
};

subtest 'hosetsu_tekiyo' => sub {
    my %opts = %option;

    my $text = '※［＃「漑－さんずい」、第3水準1-85-11］' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'hosetsu_tekiyo'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '※［＃「漑－さんずい」、第3水準1-85-11］ → [hosetsu_tekiyo]【既】 ' x 2);
};

subtest 'j78' => sub {
    my %opts = %option;

    my $text = '唖然' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'78'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '唖 [78]【唖】（第三水準1-15-8に） 然' x 2);
};

subtest 'jyogai' => sub {
    my %opts = %option;

    my $text = '戻戾' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'jyogai'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '戻 [jyogai]【戻】 戾' x 2);
};

subtest 'gonin1' => sub {
    my %opts = %option;

    my $text = '目白' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'gonin1'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '目 [gonin1]【目】（中にあるのは横棒二本） 白 [gonin1]【白】（中にあるのは横棒一本） ' x 2);
};

subtest 'gonin2' => sub {
    my %opts = %option;

    my $text = '沖縄の冲方丁' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'gonin2'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '沖 [gonin2]【沖】（さんずい） 縄の冲 [gonin2]【冲】（にすい） 方丁' x 2);
};

subtest 'gonin3' => sub {
    my %opts = %option;

    my $text = '桂さんが柱壊した' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'gonin3'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '桂 [gonin3]【桂】（かつら） さんが柱 [gonin3]【柱】（はしら） 壊した' x 2);
};

subtest 'simplesp' => sub {
    my %opts = %option;

    my $text = '太宰 治　の小説' x 2;

    my $checker1 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker1->check($text), $text);

    $opts{'simplesp'} = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '太宰_治□の小説' x 2);
};

subtest 'simplesp, hansp & zensp' => sub {
    my %opts = %option;

    my $text = '太宰 治　の小説' x 2;

    $opts{'simplesp'} = 1;
    $opts{'hansp'}    = 1;
    $opts{'zensp'}    = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '太宰_治□の小説' x 2);
};

subtest 'gaiji, 78hosetsu_tekiyo & hosetsu_tekiyo' => sub {
    my %opts = %option;

    my $text = '鷗※［＃「區＋鳥」、第3水準1-94-69］既※［＃「漑－さんずい」、第3水準1-85-11］' x 1000;

    $opts{'gaiji'}            = 1;
    $opts{'78hosetsu_tekiyo'} = 1;
    $opts{'hosetsu_tekiyo'}   = 1;

    my $checker2 = AozoraBunko::Tools::Checkerkun->new(\%opts);
    is($checker2->check($text), '鷗 [gaiji]【鷗】 ※［＃「區＋鳥」、第3水準1-94-69］ → [78hosetsu_tekiyo]【鴎】 既 [gaiji]【既】 ※［＃「漑－さんずい」、第3水準1-85-11］ → [hosetsu_tekiyo]【既】 ' x 1000);
};

subtest 'hash size' => sub {
    is(scalar keys %{$AozoraBunko::Tools::Checkerkun::KUTENMEN_78HOSETSU_TEKIYO}, 29);
    is(scalar keys %{$AozoraBunko::Tools::Checkerkun::KUTENMEN_HOSETSU_TEKIYO},   104);
    is(scalar keys %{$AozoraBunko::Tools::Checkerkun::JYOGAI},                    104);
    is(scalar keys %{$AozoraBunko::Tools::Checkerkun::J78},                       29);
};

done_testing;
