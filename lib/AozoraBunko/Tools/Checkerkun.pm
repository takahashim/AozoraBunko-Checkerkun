package AozoraBunko::Tools::Checkerkun;
our $VERSION = "0.01";

use 5.008001;
use strict;
use warnings;
use utf8;

use File::ShareDir qw//;
use YAML::Tiny     qw//;

my $yaml_file  = File::ShareDir::dist_file('AozoraBunko-Tools-Checkerkun', 'kutenmen_78hosetsu_tekiyo_utf8.yml');
our $YAML = YAML::Tiny->read($yaml_file);

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
