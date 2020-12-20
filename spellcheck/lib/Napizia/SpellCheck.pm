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
our @EXPORT = qw( correct );

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  vocabulary list
my $infile = "/home/eryk/research/flatiron/github/05-01_EconoLingual/vocab-lists/sicilian/dieli-list.txt";

##  lemmatized sicilian text
my $sicilian = "/home/eryk/research/flatiron/github/05-00_mod-five/00-00_Sicilian_Translator/embeddings/dataset/train-mparamu_v2-lemmatized.sc";

##  place Arthur Dieli's vocabulary into a "number of words" hash
my %NWORDS;
open( INFILE, $infile) || die "could not open $infile";
while (<INFILE>) {
    chomp;
    my $line = $_;
    $NWORDS{$line} += 1 ;
}
close INFILE;

##  add counts if in Arthur Dieli's vocabulary
open( SICILIAN, $sicilian) || die "could not open $sicilian";
while (<SICILIAN>) {
    chomp;
    my $line = $_;
    my @words = split( /\s/ , $line);

    foreach my $word (@words) {
	if ( ! defined $NWORDS{$word} ) {
	    my $blah = "do nothing";
	} else {
	    $NWORDS{$word} += 1 ;
	}
    }
}
close SICILIAN;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  list of characters
## my @allchars = ('0'..'9', 'A'..'Z', 'a'..'z', split("","ÀàÂâÁáÇçÈèÊêÉéÌìÎîÍíÏïÒòÔôÓóÙùÛûÚú"));
my @allchars = ('A'..'Z', 'a'..'z', split("","ÀàÈèÌìÒòÙùÂâÊêÎîÔôÛû"));

##  make single edits to the word
sub edit_once {
    my $inword = $_[0];

    ##  make position index array
    my $plen_word = length($inword) - 1;
    my @pos_index = (0..$plen_word);

    ##  use position index to split word into beginning and ending
    ##  then trim a letter, swap a letter and insert a letter
    my @edits = map {
	##  fetch beginning and ending
	my ($bgn, $end) = @{$_};
	
	##  trim, swap and insert
	my $trim_letter  = $bgn . substr($end, 1) ;
	my $swap_letter;
	{ no warnings;
	  $swap_letter = $bgn . substr($end, 1, 1) . substr($end, 0, 1) . substr($end, 2); }
	my @inserts = map { ($bgn . $_ . substr($end,1) , $bgn . $_ . $end) } @allchars ;
	
	##  create the array for mapping
	( $trim_letter , $swap_letter , @inserts );
	
    } map {
	##  beginning of word , ending of word
	[substr($inword, 0, $_), substr($inword, $_)]
    } @pos_index ;

    ##  return the edits
    return @edits;
}


##  for two edits, repeat the process
sub edit_twice {
    my $inword = $_[0];
    my @edits  = map { edit_once($_) } edit_once($inword);
    return @edits;
}


##  predict correct spelling based on "number of words"
sub correct {
    my $inword = $_[0];
    my $otword = $inword;
    
    foreach my $word (edit_once($inword), edit_twice($inword)) {
	$otword = ($NWORDS{$word} > $NWORDS{$otword}) ? $word : $otword ;
    }
    return $otword . " -- " . $NWORDS{$otword};
} 
