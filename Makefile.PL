use inc::Module::Install;

name     'App-Distbrew';
all_from 'lib/App/Distbrew.pm';

requires 'Pod::Usage' => 0;
requires 'Pod::Find'  => 0;

WriteAll;
