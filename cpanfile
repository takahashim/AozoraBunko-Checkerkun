requires 'perl', '5.008001';

requires 'Carp';
requires 'Exporter';
requires 'File::ShareDir';
requires 'YAML', '>= 1.15';

on 'test' => sub {
    requires 'Test::More', '>= 0.98';
};
