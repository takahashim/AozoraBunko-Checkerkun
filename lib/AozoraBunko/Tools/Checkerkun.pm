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
        gaiji              => 1, # JIS外字をチェックする
        hansp              => 1, # 半角スペースをチェックする
        hanpar             => 1, # 半角カッコなどの記号をチェックする
        zensp              => 0, # 全角スペースをチェックする
        '78hosetsu_tekiyo' => 1, # 78互換包摂の対象となる不要な外字注記をチェックする
        hosetsu_tekiyo     => 1, # 包摂の対象となる不要な外字注記をチェックする
        78                 => 0, # 78互換包摂29字をチェックする
        jyogai             => 0, # 新JIS漢字で包摂規準の適用除外となる104字をチェックする
        gonin1             => 0, # 誤認しやすい文字をチェックする(1)
        gonin2             => 0, # 誤認しやすい文字をチェックする(2)
        gonin3             => 0, # 誤認しやすい文字をチェックする(3)
        simplesp           => 0, # 半角スペースは赤文字 _で、全角スペースは赤文字□で出力する
        pre                => 0, # 入力した通りに改行して出力する
        bold               => 0, # 太字も用いて出力する
    };
}

sub new
{
    my $class = shift;
    my %args  = (ref $_[0] eq 'HASH' ? %{$_[0]} : @_);

    my $options = $class->_default_options;

    for my $key (keys %args)
    {
        if ( ! exists $options->{$key} ) { Carp::croak "Unknown option: '$key'";  }
        else                             { $options->{$key} = $args{$key};        }
    }

    bless $options, $class;
}

# 例：
# ［＃「口＋亞」、第3水準1-15-8、144-上-9］
# が
# ［＃「口＋亞」、第3水準1-15-8、144-上-9］ → [78hosetsu_tekiyo]【唖】
# に変換される。
sub _check_78hosetsu_tekiyo
{
    my ($text) = @_;

    my $replace = $text;

    if ($text =~ /［＃.*?水準(\d+\-\d+\-\d+).*?］/)
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
sub _check_hosetsu_tekiyo
{
    my ($text) = @_;

    my $replace = '';

    if ($text =~ m|［＃.*?水準(\d+\-\d+\-\d+).*?］|)
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

    my ($state, $checked_text);

    my @chars = split(//, $text);

    for my $char (@chars)
    {
        $checked_text .= $char;
        $checked_text .= " [gaiji]【$char】 " if $self->{'gaiji'}  && _is_gaiji($char);
    }

    return $checked_text;
    return _check_78hosetsu_tekiyo($text);
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
  $checker->check('森鷗［＃「區＋鳥」、第3水準1-94-69］外');


=head1 DESCRIPTION

AozoraBunko::Tools::Checkerkun は、青空文庫工作員のための文字チェッカーで、結城浩氏が作成したツールを私がライブラリ化したものです。

=head1 LICENSE

Copyright (C) pawa.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

pawa E<lt>pawa@pawafuru.comE<gt>

=cut
