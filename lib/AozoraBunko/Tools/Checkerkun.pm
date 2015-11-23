package AozoraBunko::Tools::Checkerkun;
our $VERSION = "0.01";

use 5.008001;
use strict;
use warnings;
use utf8;

use Carp           qw//;
use File::ShareDir qw//;
use YAML::Tiny     qw//;
use Encode         qw//;
use Lingua::JA::Halfwidth::Katakana;

my $YAML_FILE = File::ShareDir::dist_file('AozoraBunko-Tools-Checkerkun', 'hiden_no_tare.yml');
my $YAML = YAML::Tiny->read($YAML_FILE)->[0];
my $ENC = Encode::find_encoding("Shift_JIS");

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

sub _default_options
{
    return {
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
    };
}

sub new
{
    my $class = shift;
    my %args  = (ref $_[0] eq 'HASH' ? %{$_[0]} : @_);

    my $options = $class->_default_options;

    for my $key (keys %args)
    {
        if ( ! exists $options->{$key} ) { Carp::croak "Unknown option: '$key'"; }
        else                             { $options->{$key} = $args{$key};       }
    }

    bless $options, $class;
}

# 例：
#
# ［＃「口＋亞」、第3水準1-15-8、144-上-9］
# が
# ［＃「口＋亞」、第3水準1-15-8、144-上-9］ → [78hosetsu_tekiyo]【唖】
# に変換され、
#
#［＃「にんべん＋曾」、第3水準1-14-41、144-上-9］
# が
#［＃「にんべん＋曾」、第3水準1-14-41、144-上-9］→[hosetsu_tekiyo]【僧】
# に変換される。
#
sub _check_all_hosetsu_tekiyo
{
    my ($self, $chars_ref, $index) = @_;

    my ($replace, $usedlen);

    my $rear_index = $index + 80;
    $rear_index = $#{$chars_ref} if $rear_index > $#{$chars_ref};

    if ( join("", @{$chars_ref}[$index .. $rear_index]) =~ /^［(＃.*?水準(\d+\-\d+\-\d+).*?］)/ )
    {
        my $match    = $1;
        my $kutenmen = $2;

        if ( $self->{'78hosetsu_tekiyo'} && exists $KUTENMEN_78HOSETSU_TEKIYO->{$kutenmen} )
        {
            $replace = $match . ' → [78hosetsu_tekiyo]【' . $KUTENMEN_78HOSETSU_TEKIYO->{$kutenmen} . '】 ';
            $usedlen = length $match;
        }
        elsif ( $self->{'hosetsu_tekiyo'} && exists $KUTENMEN_HOSETSU_TEKIYO->{$kutenmen} )
        {

            $replace = $match . ' → [hosetsu_tekiyo]【' . $KUTENMEN_HOSETSU_TEKIYO->{$kutenmen} . '】 ';
            $usedlen = length $match;
        }
    }

    return ($replace, $usedlen);
}

sub _is_gaiji
{
    # UTF-8からSJISに変換できなければ外字と判定
    eval { $ENC->encode($_[0], Encode::FB_CROAK) };
    return 1 if $@;
    return 0;
}

sub check
{
    my ($self, $text) = @_;

    return undef unless defined $text;

    my @chars = split(//, $text);

    my $checked_text = '';

    for (my $i = 0; $i < @chars; $i++)
    {
        my $char = $chars[$i];

        if ($self->{simplesp})
        {
            $char = '_'  if $char eq "\x{0020}";
            $char = '□' if $char eq "\x{3000}";
        }

        $checked_text .= $char;

        if ($char =~ /[\x{0000}-\x{0009}\x{000B}\x{000C}\x{000E}-\x{001F}\x{007F}-\x{009F}]/)
        {
            # 改行は含まない
            $checked_text .= " [ctrl]【" . sprintf("U+%04X", ord $char) . "】 ";
        }
        elsif ($char =~ /\p{InHalfwidthKatakana}/)
        {
            $checked_text .= " [hankata]【$char】 ";
        }
        elsif ($self->{'hansp'} && $char =~ "\x{0020}")
        {
            $checked_text .= " [hansp]【$char】 ";
        }
        elsif ($self->{'zensp'} && $char eq "\x{3000}")
        {
            $checked_text .= " [zensp]【$char】 ";
        }
        elsif ( $self->{hanpar} && ($char eq '(' || $char eq ')') )
        {
            $checked_text .= " [hanpar]【$char】 ";
        }
        elsif ( $char eq '［' && ($self->{'78hosetsu_tekiyo'} || $self->{'hosetsu_tekiyo'}) )
        {
            my ($replace, $usedlen) = $self->_check_all_hosetsu_tekiyo(\@chars, $i);

            if ($replace)
            {
                $checked_text .= $replace;
                $i += $usedlen;
                next;
            }
        }
        else
        {
            if ($self->{'78'} && $J78->{$char})
            {
                $checked_text .= " [78]【$char】（" . $J78->{$char} . "） ";
            }
            elsif ($self->{'jyogai'} && $JYOGAI->{$char})
            {
                $checked_text .= " [jyogai]【$char】 ";
            }
            elsif ($self->{'gonin1'} && $GONIN1->{$char})
            {
                $checked_text .= " [gonin1]【$char】（" . $GONIN1->{$char} . "） ";
            }
            elsif ($self->{'gonin2'} && $GONIN2->{$char})
            {
                $checked_text .= " [gonin2]【$char】（" . $GONIN2->{$char} . "） ";
            }
            elsif ($self->{'gonin3'} && $GONIN3->{$char})
            {
                $checked_text .= " [gonin3]【$char】（" . $GONIN3->{$char} . "） ";
            }
        }

        $checked_text .= " [gaiji]【$char】 " if $self->{'gaiji'} && _is_gaiji($char);
    }


    return $checked_text;
}

1;

__END__

=encoding utf-8

=head1 NAME

AozoraBunko::Tools::Checkerkun - 青空文庫の工作員のための文字チェッカー（作：結城浩）をライブラリ化したもの

=head1 SYNOPSIS

  use AozoraBunko::Tools::Checkerkun;
  use utf8;

  my $checker = AozoraBunko::Tools::Checkerkun->new();
  $checker->check('森鴎［＃「區＋鳥」、第3水準1-94-69］外💓'); # => '森鴎［＃「區＋鳥」、第3水準1-94-69］ → [78hosetsu_tekiyo]【鴎】 外💓 [gaiji]【💓】 '


=head1 DESCRIPTION

AozoraBunko::Tools::Checkerkun は、青空文庫工作員のための文字チェッカーで、結城浩氏が作成したツールを私がライブラリ化したものです。

=head1 METHODS

=head2 $checker = AozoraBunko::Tools::Checkerkun->new(\%option)

新しい Aozorabunko::Tools::Checkerkun インスタンスを生成する。

  my $checker = AozoraBunko::Tools::Checkerkun->new(
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

上記のコードで設定されている値がデフォルト値です。

=head2 $checked_text = $checker->check($text)

new で指定したオプションでテキストをチェックします。戻り値はチェック済みのテキストです。

=head1 LICENSE

Copyright (C) pawa.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<チェッカー君|http://www.aozora.jp/tools/checker.cgi>

L<外字|http://www.aozora.gr.jp/annotation/external_character.html>

L<包摂 (文字コード) - Wikipedia|https://ja.wikipedia.org/wiki/%E5%8C%85%E6%91%82_(%E6%96%87%E5%AD%97%E3%82%B3%E3%83%BC%E3%83%89)>

L<JIS漢字で包摂の扱いが変わる文字（[78] [jyogai] など）|http://www.aozora.gr.jp/newJIS-Kanji/gokan_henkou_list.html>

=head1 AUTHOR

pawa E<lt>pawa@pawafuru.comE<gt>

=cut
