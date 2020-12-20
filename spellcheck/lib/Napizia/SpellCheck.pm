package Napizia::SpellCheck;

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
no warnings qw(uninitialized);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw( dedup edits1 edits2 correct );

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

my $infile = "/home/eryk/research/flatiron/github/05-01_EconoLingual/vocab-lists/sicilian/dieli-list.txt";
    
my %NWORDS;
open( INFILE, $infile) || die "could not open $infile";
while (<INFILE>) {
    chomp;
    my $line = $_;
    $NWORDS{$line} += 1 ;
}
close INFILE;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub dedup {
    my %hash = map { $_, 1 } @_;
    return keys %hash;
}

sub edits1 {
    my $word = shift;

    dedup( map { ($a, $b) = @{$_};
		 { no warnings;
		   ( $a . substr($b, 1),
		     $a . substr($b, 1, 1) . substr($b, 0, 1) . substr($b, 2),
		     map { ($a . $_ . substr($b,1), $a . $_ . $b) } 'a'..'z' );
		 }
	   } map {
	       [substr($word, 0, $_), substr($word, $_)]
	   }
	   0..length($word)-1
	);
}

sub edits2 {
    dedup( map { edits1($_) } edits1(shift));
}

sub correct {
    my $win = shift;
    
    for (edits1($win), edits2($win)) {
	$win = $_ if ($NWORDS{$_} > $NWORDS{$win});
    }
    return $win;
} 
