use inc::Module::Install;

name     'App-ModBrew';
all_from 'lib/App/ModBrew.pm';

requires 'Pod::Usage' => 0;
requires 'Pod::Find'  => 0;

WriteAll;
