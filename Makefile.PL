use inc::Module::Install;

name     'MapReduce UI';
abstract 'MapReduce UI is a web UI for MapReduce.';
author   'James Barton <james@revolet.com>';
version  '0.13';
license  'MIT';

requires 'Redis::hiredis' => 0;
requires 'Mojolicious'    => 0;

test_requires 'Test::Deep' => 0;
test_requires 'Test::More' => 0;

auto_install();

WriteAll();

