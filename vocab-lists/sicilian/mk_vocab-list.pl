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

##  get list of Arthur Dieli's Sicilian and the unrolled Cchiu

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

##  cchiu hashes and subroutines
my $vthash  = retrieve('/home/eryk/website/napizia/cgi-lib/verb-tools' );
my $vbconj  = $vthash->{vbconj} ;
my $vbsubs  = $vthash->{vbsubs} ;
my $nounpls = $vthash->{nounpls} ;

my $vnhash = retrieve('/home/eryk/website/napizia/cgi-lib/vocab-notes' );
my %vnotes = %{ $vnhash } ;

my $cchash = retrieve('/home/eryk/website/napizia/cgi-lib/cchiu-tools' );
my %ccsubs = %{ $cchash->{ccsubs} } ;
my %ddsubs = %{ $cchash->{ddsubs} } ;

##  output file
my $otfile = "dieli-cchiu-vocab.txt";

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

##  unroll CCHIU
foreach my $inword (sort keys %vnotes) {

    ##  are we working with a verb, noun or adjective?
    my $isverb = ( ! defined $vnotes{ $inword }{verb}     && 
		   ! defined $vnotes{ $inword }{reflex}   && 
		   ! defined $vnotes{ $inword }{prepend}            ) ? "false" : "true" ;
    my $isnoun = ( ! defined $vnotes{ $inword }{noun}               ) ? "false" : "true" ;
    my $isadj  = ( $vnotes{ $inword }{part_speech} ne "adj" ) ? "false" : "true" ;

    ##  "other" parts of speech currently include:  {adv} {prep} {pron}
    my $isother  = ( ! defined $vnotes{ $inword }{part_speech} ) ? "false" : "true" ;

    ##  gotta specify the relics
    my $lgparm = "SCEN";

    ##  go through the parts of speech
    if ( $isverb eq "true" ) {
	my @verbs = get_verb_forms( $inword , $lgparm , \%vnotes , $vbconj , $vbsubs );
	push(@scarray , @verbs);
	
    } elsif ( $isnoun eq "true" ) {
	my @nouns = get_noun_forms( $inword , $lgparm , \%vnotes , $nounpls , $vbsubs );
	push(@scarray , @nouns);
	
    } elsif ( $isadj  eq "true" ) {
	my @adjs = get_adj_forms( $inword , $lgparm , \%vnotes , $vbsubs );
	push(@scarray , @adjs);

    } elsif ( $isother  eq "true" ) {
	##  strip part of speech identifier
	my $strip = $inword;
	$strip =~ s/_[a-z]*$//;

	##  what is the display?
	my $display = ( ! defined $vnotes{$inword}{display_as} ) ? $strip : $vnotes{$inword}{display_as}; 
	push(@scarray , $display);	
    }
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  rid accents, sort and make unique
@scarray = map { rid_accents($_) } @scarray ;
@scarray = uniq( sort { $a cmp $b } @scarray );

##  we want single words, so ... combine, split and make unique
my $sc_combo =  join( " " , @scarray );
my @sc_split = split( / / , $sc_combo);
@sc_split    = map {lc($_)} @sc_split;
my @sc_uniq  = uniq( sort { $a cmp $b } @sc_split );

##  print the dictionaries
open( OTFILE , ">$otfile" ) || die "could not overwrite $otfile";
foreach my $palora (@sc_uniq) {
    if ( $palora =~ /[a-z]/ ) {
	print OTFILE $palora ."\n";
    }
}
close OTFILE ;


