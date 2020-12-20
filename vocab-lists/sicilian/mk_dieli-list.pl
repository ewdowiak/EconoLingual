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

##  get list of Arthur Dieli's Sicilian

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

use strict;
use warnings;
use Storable qw( retrieve ) ;
{   no warnings;             
    ## $Storable::Deparse = 1;  
    $Storable::Eval    = 1;  
}
## use utf8;

use lib $ENV{PWD} .'/lib';
use Napizia::MakeVocab;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  dieli dictionary
my %dieli = %{ retrieve('/home/eryk/website/napizia/cgi-lib/dieli-sc-dict') };

##  output file
my $otfile = "dieli-list.txt";

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  word holder
my @scarray;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  capture DIELI dictionary entries
foreach my $palora ( sort keys %dieli ) {
    for my $i (0..$#{$dieli{$palora}}) {
	
	##  get the entry
	my $scword = ${$dieli{$palora}[$i]}{"sc_word"} ;
	
	##  get rid of spacing,
	if ( $scword =~ /- - - - -/ ) {
	    ##  get rid of spacing
	    my $blah = "do nothing";

	} else {
	    
	    ##  strip out what we do not want
	    $scword =~ s/_SQUOTE_/'/g;

	    ##  switch selected accents to apostrophes
	    $scword = ( $scword eq "sì"  ) ? "si'"  : $scword;
	    $scword = ( $scword eq "è"   ) ? "e'"   : $scword;
	    $scword = ( $scword eq "c'è" ) ? "c'e'" : $scword;
	    $scword = ( $scword eq "n'è" ) ? "n'e'" : $scword;

	    ##  replace abbreviated article with full form
	    $scword = ( $scword eq "'u" ) ? "lu" : $scword;
	    $scword = ( $scword eq "'a" ) ? "la" : $scword;
	    $scword = ( $scword eq "'i" ) ? "li" : $scword;

	    ##  place space after apostrophe
	    $scword =~ s/'/' /g;

	    ##  remove punctuation
	    $scword =~ s/[\,\.\!\?]//g;

	    ##  strip out what we do not want
	    $scword =~ s/\(.*\)/ /g;
	    $scword =~ s/\s+/ /g;
	    $scword =~ s/^\s//g;
	    $scword =~ s/\s$//g;

	    ##  make lower case
	    $scword = lc( $scword );

	    ##  push it onto the holder
	    push( @scarray , $scword );
	}
    }
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  rid accents, sort and make unique
#@scarray = map { rid_accents($_) } @scarray ;
@scarray = uniq( sort { $a cmp $b } @scarray );

##  print the dictionary
open( OTFILE , ">$otfile" ) || die "could not overwrite $otfile";
foreach my $palora (@scarray) { 
    if ( $palora =~ /[a-z]/ ) {
	print OTFILE $palora ."\n";
    }
}
close OTFILE ;


