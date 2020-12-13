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


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES
##  ===========

##  tip of the hat to List::MoreUtils for this sub
sub uniq { 
    my %h;
    map { $h{$_}++ == 0 ? $_ : () } @_;
}

##  remove unicode accents from vowels
sub rid_accents {
    my $str = $_[0] ;
    
    ##  rid grave accents
    $str =~ s/\303\240/a/g; 
    $str =~ s/\303\250/e/g; 
    $str =~ s/\303\254/i/g; 
    $str =~ s/\303\262/o/g; 
    $str =~ s/\303\271/u/g; 
    $str =~ s/\303\200/A/g; 
    $str =~ s/\303\210/E/g; 
    $str =~ s/\303\214/I/g; 
    $str =~ s/\303\222/O/g; 
    $str =~ s/\303\231/U/g; 
    
    ##  rid acute accents
    $str =~ s/\303\241/a/g; 
    $str =~ s/\303\251/e/g; 
    $str =~ s/\303\255/i/g; 
    $str =~ s/\303\263/o/g; 
    $str =~ s/\303\272/u/g; 
    $str =~ s/\303\201/A/g; 
    $str =~ s/\303\211/E/g; 
    $str =~ s/\303\215/I/g; 
    $str =~ s/\303\223/O/g; 
    $str =~ s/\303\232/U/g; 
    
    ##  rid circumflex accents
    $str =~ s/\303\242/a/g; 
    $str =~ s/\303\252/e/g; 
    $str =~ s/\303\256/i/g; 
    $str =~ s/\303\264/o/g; 
    $str =~ s/\303\273/u/g; 
    $str =~ s/\303\202/A/g; 
    $str =~ s/\303\212/E/g; 
    $str =~ s/\303\216/I/g; 
    $str =~ s/\303\224/O/g; 
    $str =~ s/\303\233/U/g; 

    ##  rid diaeresis accents
    $str =~ s/\303\244/a/g;
    $str =~ s/\303\253/e/g;
    $str =~ s/\303\257/i/g;
    $str =~ s/\303\266/o/g;
    $str =~ s/\303\274/u/g;
    $str =~ s/\303\204/A/g;
    $str =~ s/\303\213/E/g;
    $str =~ s/\303\217/I/g;
    $str =~ s/\303\226/O/g;
    $str =~ s/\303\234/U/g;

    ##  Ç = "\303\207"
    ##  ç = "\303\247"
    $str =~ s/\303\207/c/g;
    $str =~ s/\303\247/C/g; 

    return $str ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub get_noun_forms { 
    my $palora  =    $_[0]   ;  ( my $singular = $palora ) =~ s/_noun$// ; 
    my $lgparm  =    $_[1]   ;
    my %vnotes  = %{ $_[2] } ;
    my $nounpls =    $_[3]   ;  ##  hash reference
    my %vbsubs  = %{ $_[4] } ;  

    ##  first choice is "display_as",  second choice is hash key (less noun marker)
    my $display = ( ! defined $vnotes{$palora}{display_as} ) ? $singular : $vnotes{$palora}{display_as} ; 

    ##  $vbsubs{mk_noun_plural}() assumes "mas" or "fem" noun, some nouns are "both"
    ##  such "both" nouns end in "-a" in singular and "-i" in plural
    ##  the sub is written in such a way that it should be able to handle "both"
    my $gender = $vnotes{$palora}{noun}{gender} ; 
    my $plend = $vnotes{$palora}{noun}{plend} ; 
    
    ##  array to hold each form
    my @noun_forms;

    ##  singular forms
    if ( $gender eq "mas"|| $gender eq "fem" || $gender eq "both" ) {
	push( @noun_forms, $display );
    }

    ##  set up plural as array -- for the plends: "xixa" and "xura"
    ##  leave "@plurals" undefined if no plural
    my @plurals ;
    if ( $plend eq "nopl" ) {
	my $blah = "no plural.";
    } elsif ( $plend eq "ispl" ) {
	##  already plural
	push( @noun_forms , $display ) ; 

    } elsif ( ! defined $vnotes{$palora}{noun}{plural} && ( $plend eq "xixa" || $plend eq "xura" || $plend eq "eddu" ) ) {
	##  if an irregular plural is not defined AND plend is either "xixa" or "xura"
	push( @noun_forms , $vbsubs{mk_noun_plural}( $display , $gender , $plend  , $nounpls ) );
	push( @noun_forms , $vbsubs{mk_noun_plural}( $display , $gender , "xi"  , $nounpls ) );

    } elsif ( ! defined $vnotes{$palora}{noun}{plural} ) {
	##  if an irregular plural is not defined
	push( @noun_forms , $vbsubs{mk_noun_plural}( $display , $gender , $plend  , $nounpls ) );

    } else {
	##  if an irregular plural is defined
	push( @noun_forms , $vnotes{$palora}{noun}{plural} );
    }
    
    ##  make the list unique and return it
    @noun_forms = uniq(@noun_forms);
    return @noun_forms;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub get_adj_forms { 
    my $palora  =    $_[0]   ;  ( my $singular = $palora ) =~ s/_adj$// ; 
    my $lgparm  =    $_[1]   ;
    my %vnotes  = %{ $_[2] } ;
    my %vbsubs  = %{ $_[3] } ;  

    ##  first choice is "display_as",  second choice is hash key (less adj marker)
    my $display = ( ! defined $vnotes{$palora}{display_as} ) ? $singular : $vnotes{$palora}{display_as} ;	

    ##  holder for the forms
    my @adj_forms;
    
    ##  if it is not an adjective phrase 
    if ( ! defined $vnotes{$palora}{adj}{phrase} ) {

	##  fetch singular and plural forms
	my $massi ; my $femsi ; my $maspl ; my $fempl ;
	
	##  check to see if adjective is invariant (e.g. "la megghiu cosa") 
	##  or only feminine changes (e.g. "giuvini, giuvina")
	if ( ! defined $vnotes{$palora}{adj}{invariant} && 
	     ! defined $vnotes{$palora}{adj}{femsi} && 
	     ! defined $vnotes{$palora}{adj}{plural} ) {
	    ##  not invariant, regular femsi and regular plural
	    ($massi , $femsi , $maspl , $fempl) = $vbsubs{mk_adjectives}($display) ;
	} elsif ( ! defined $vnotes{$palora}{adj}{plural} ) {
	    ##  either invariant or only fem form changes
	    $massi = $display  ;  
	    $femsi = ( ! defined $vnotes{$palora}{adj}{femsi}  ) ? $display : $vnotes{$palora}{adj}{femsi} ;
	    $maspl = $display ;
	    $fempl = $display ;
	} else {
	    ##  plural is special
	    ($massi , $femsi , $maspl , $fempl) = $vbsubs{mk_adjectives}($display) ;
	    $femsi = ( ! defined $vnotes{$palora}{adj}{femsi}  ) ? $femsi : $vnotes{$palora}{adj}{femsi} ;
	    $maspl = ( ! defined $vnotes{$palora}{adj}{plural} ) ? $maspl : $vnotes{$palora}{adj}{plural};
	    $fempl = ( ! defined $vnotes{$palora}{adj}{plural} ) ? $fempl : $vnotes{$palora}{adj}{plural};
	}
	
	##  make note of masculine singular forms that precedes the noun (if any)
	my $precede = ( ! defined $vnotes{$palora}{adj}{massi_precede} ) ? $massi : $vnotes{$palora}{adj}{massi_precede};

	##  add them to the list of forms
	push( @adj_forms , $massi );
	push( @adj_forms , $femsi );
	push( @adj_forms , $maspl );
	push( @adj_forms , $fempl );
	push( @adj_forms , $precede );
	
    } else {
	push( @adj_forms , $display )
    }

    ##  make the list unique and return it
    @adj_forms = uniq(@adj_forms);
    return @adj_forms;
}


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub get_verb_forms {
    
    my $palora =    $_[0]   ;
    my $lgparm =    $_[1]   ;
    my %vnotes = %{ $_[2] } ;
    my $vbcref =    $_[3]   ;  ##  hash reference
    my %vbsubs = %{ $_[4] } ;  
    
    my %forms  = $vbsubs{mk_forms}() ; 
    my @tenses = @{ $forms{tenses} } ; 
    my %tnhash = %{ $forms{tnhash} } ; 
    my @people = ( ! defined $vnotes{$palora}{verb}{people} ) ? @{ $forms{people} } : @{ $vnotes{$palora}{verb}{people} };

    ##  conjugate the verb
    my %othash = $vbsubs{conjugate}( $palora , \%vnotes , $vbcref , \%vbsubs ) ; 

    ##  which word do we display?
    my $display ;
    $display = ( ! defined $othash{inf} ) ? $palora : $othash{inf} ;
    $display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as} ;
    
    ##  holder for the forms
    my @verb_forms;
    
    ##  add forms to holder
    push( @verb_forms , $display );
    
    ##  PRI -- present indicative 
    foreach my $person (@people) {
	push( @verb_forms , $othash{pri}{$person}); 
    }
    
    ##  PIM -- present imperative
    push( @verb_forms , $othash{pim}{"ds"});
    push( @verb_forms , $othash{pim}{"ts"});
    push( @verb_forms , $othash{pim}{"up"});
    push( @verb_forms , $othash{pim}{"dp"});
    
    ##  PAI -- past ind. (preterite) 
    ##  IMI -- imperfect ind.
    ##  IMS -- imperfect subjunctive
    ##  FTI -- future indicative
    ##  COI -- conditional indicative
    foreach my $tense ("pai","imi","ims","fti","coi") {
	foreach my $person (@people) {
	    push( @verb_forms , $othash{$tense}{$person} ); 
	}
    }
    
    ##  GER -- gerund
    ##  PAP -- past participle
    push( @verb_forms , $othash{ger});
    push( @verb_forms , $othash{pap});
    push( @verb_forms , $othash{adj});
    

    ##  make the list unique and return it
    @verb_forms = uniq(@verb_forms);
    return @verb_forms;
}
