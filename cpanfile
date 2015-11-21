requires 'perl', '5.008001';

requires 'Carp';
requires 'Exporter';
requires 'File::ShareDir';
requires 'YAML::Tiny', '>= 1.69';

on 'test' => sub {
    requires 'Test::More', '>= 0.98';
};
