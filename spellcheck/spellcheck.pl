#!/usr/bin/env perl

##  Copyright 2020 Eryk Wdowiak
##  
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##  
##      http://www.apache.org/licenses/LICENSE-2.0
##  
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  implement Peter Norvig's spellchecker in Perl
##    *  http://norvig.com/spell-correct.html
##    *  http://www.arclang.com/item?id=10577

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

use strict;
use warnings;

use lib $ENV{PWD} .'/lib';
use Napizia::SpellCheck;

print "palora ca haiu a circari: ";
my $lookup = <STDIN>;
chomp( $lookup );

print "mi pari ca circavi:       ";
print correct($lookup) . "\n";
