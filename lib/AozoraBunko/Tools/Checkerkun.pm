package AozoraBunko::Tools::Checkerkun;
our $VERSION = "0.01";

use 5.008001;
use strict;
use warnings;
use utf8;

use File::ShareDir qw//;
use YAML::Tiny     qw//;

my $YAML_FILE = File::ShareDir::dist_file('AozoraBunko-Tools-Checkerkun', 'hiden_no_tare.yml');
my $YAML = YAML::Tiny->read($YAML_FILE)->[0];

# [78hosetsu_tekiyo] 78互換包摂の対象となる不要な外字注記をチェックする
our $KUTENMEN_78HOSETSU_TEKIYO = $YAML->{'kutenmen_78hosetsu_tekiyo'};

# [hosetsu_tekiyo] 包摂の対象となる不要な外字注記をチェックする
our $KUTENMEN_HOSETSU_TEKIYO = $YAML->{'kutenmen_hosetsu_tekiyo'};

# 新JIS漢字で包摂基準の適用除外となる104字
our $JYOGAI = $YAML->{'jyogai'};

# 78互換文字
our $J78 = $YAML->{'j78'};

# 間違えやすい文字
# かとうかおりさんの「誤認識されやすい文字リスト」から
# http://plaza.users.to/katokao/digipr/digipr_charlist.html
our $GONIN1 = $YAML->{'gonin1'};

# 誤認2
our $GONIN2 = $YAML->{'gonin2'};

# 誤認3
# （砂場清隆さんの入力による）
our $GONIN3 = $YAML->{'gonin3'};

# 例：
# ［＃「口＋亞」、第3水準1-15-8、144-上-9］
# が
# ［＃「口＋亞」、第3水準1-15-8、144-上-9］ → [78hosetsu_tekiyo]【唖】
# に変換される。
sub check_78hosetsu_tekiyo
{
    my ($text) = @_;

    my $replace = '';

    if ($text =~ m|^［＃.*?水準(¥d+¥-¥d+¥-¥d+).*?］|)
    {
        my $kutenmen = $1;
        my $match    = $&;

        if ( exists $KUTENMEN_78HOSETSU_TEKIYO->{$kutenmen} )
        {
            $replace = $match . ' → [78hosetsu_tekiyo]【' . $KUTENMEN_78HOSETSU_TEKIYO->{$kutenmen} . '】';
            #$replace = "$greenbegin$replace$greenend";
        }
    }

    return $replace;
}

# 例：
#［＃「にんべん＋曾」、第3水準1-14-41、144-上-9］
# が
#［＃「にんべん＋曾」、第3水準1-14-41、144-上-9］→[hosetsu_tekiyo]【僧】
# に変換される。
sub check_hosetsu_tekiyo
{
    my ($text) = @_;

    my $replace = '';

    if ($text =~ m|^［＃.*?水準(¥d+¥-¥d+¥-¥d+).*?］|)
    {
        my $kutenmen = $1;
        my $match    = $&;

        if ( exists $KUTENMEN_HOSETSU_TEKIYO->{$kutenmen} )
        {
            $replace = $match . ' → [hosetsu_tekiyo]【' . $KUTENMEN_HOSETSU_TEKIYO->{$kutenmen} . '】';
            #$replace = "$greenbegin$replace$greenend";
        }
    }

    return $replace;
}

sub is_gaiji
{
    my $val = shift;

    # UTF-8からSJISに変換できなければ外字と判定するように修正する

    return 1
      if 0x81AD <= $val && $val <= 0x81B7 ||
         0x81C0 <= $val && $val <= 0x81C7 ||
         0x81CF <= $val && $val <= 0x81D9 ||
         0x81E9 <= $val && $val <= 0x81EF ||
         0x81F8 <= $val && $val <= 0x81FB ||
         0x8240 <= $val && $val <= 0x824E ||
         0x8259 <= $val && $val <= 0x825F ||
         0x827A <= $val && $val <= 0x8280 ||
         0x829B <= $val && $val <= 0x829E ||
         0x82F2 <= $val && $val <= 0x82FC ||
         0x8397 <= $val && $val <= 0x839E ||
         0x83B7 <= $val && $val <= 0x83BE ||
         0x83D7 <= $val && $val <= 0x83FC ||
         0x8461 <= $val && $val <= 0x846F ||
         0x8492 <= $val && $val <= 0x849E ||
         0x84BF <= $val && $val <= 0x84FC ||
         0x8540 <= $val && $val <= 0x859E ||
         0x859F <= $val && $val <= 0x85FC ||
         0x8640 <= $val && $val <= 0x869E ||
         0x869F <= $val && $val <= 0x86FC ||
         0x8740 <= $val && $val <= 0x879E ||
         0x879F <= $val && $val <= 0x87FC ||
         0x8840 <= $val && $val <= 0x889E ||
         0x9873 <= $val && $val <= 0x989E ||
         0xEAA5 <= $val && $val <= 0xEAFC ||
         0xEB40 <= $val && $val <= 0xEB9E ||
         0xEB9F <= $val && $val <= 0xEBFC ||
         0xEC40 <= $val && $val <= 0xEC9E ||
         0xEC9F <= $val && $val <= 0xECFC ||
         0xED40 <= $val && $val <= 0xED9E ||
         0xED9F <= $val && $val <= 0xEDFC ||
         0xEE40 <= $val && $val <= 0xEE9E ||
         0xEE9F <= $val && $val <= 0xEEFC ||
         0xEF40 <= $val && $val <= 0xEF9E ||
         0xEF9F <= $val && $val <= 0xEFFC ||
         0xF040 <= $val && $val <= 0xFCFC # Extra
    ;

    return 0;
}

sub check
{
    my ($text) = @_;

    my $state;

    my @chars = split(//, $text);

    for my $char (@chars)
    {
        my $replace = check_78hosetsu_tekiyo($text);
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

AozoraBunko::Tools::Checkerkun - 青空文庫の工作員のための文字チェッカー（作：結城浩）をライブラリ化したもの

=head1 SYNOPSIS

    use AozoraBunko::Tools::Checkerkun;

=head1 DESCRIPTION

AozoraBunko::Tools::Checkerkun は、青空文庫工作員のための文字チェッカーで、結城浩が作成したツールを私がライブラリ化したものです。

=head1 LICENSE

Copyright (C) pawa.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

pawa E<lt>pawa@pawafuru.comE<gt>

=cut
