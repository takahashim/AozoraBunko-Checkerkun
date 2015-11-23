# NAME

AozoraBunko::Tools::Checkerkun - 青空文庫の工作員のための文字チェッカー（作：結城浩）をライブラリ化したもの

# SYNOPSIS

    use AozoraBunko::Tools::Checkerkun;
    use utf8;

    my $checker = AozoraBunko::Tools::Checkerkun->new();
    $checker->check('森鴎［＃「區＋鳥」、第3水準1-94-69］外💓'); # => '森鴎［＃「區＋鳥」、第3水準1-94-69］ → [78hosetsu_tekiyo]【鴎】 外💓 [gaiji]【💓】 '

# DESCRIPTION

AozoraBunko::Tools::Checkerkun は、青空文庫工作員のための文字チェッカーで、結城浩氏が作成したツールを私がライブラリ化したものです。

# LICENSE

Copyright (C) pawa.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

pawa <pawa@pawafuru.com>
