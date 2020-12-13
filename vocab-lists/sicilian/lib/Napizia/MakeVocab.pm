package Napizia::MakeVocab;

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

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw( uniq rid_accents get_noun_forms get_adj_forms get_verb_forms );

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

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
