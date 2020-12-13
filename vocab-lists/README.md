# EconoLingual / vocab-lists

While developing [_Tradutturi Sicilianu_](https://translate.napizia.com), we obtained large improvements in translation quality by biasing the learned [subword vocabulary](https://www.doviak.net/pages/ml-sicilian/ml-scn_p04.shtml) towards the desinences one finds in a textbook.  The method requires a vocabulary list for each language, so this directory creates them.

###  background

To bias the learned subword vocabulary towards the desinences one finds in a textbook, we added a unique list of words and the inflections of verbs, nouns and adjectives to the Sicilian data when learning the [byte-pair encoding](https://github.com/rsennrich/subword-nmt).  Because each word was only added once, none of them affected the distribution of whole words.  But once the words were split, they greatly affected the distribution of subwords, filling it with stems and suffixes.

And because the resulting subword vocabulary is similar to the theoretical stems and desinences of a textbook, the machine learned to translate in a more theoretical way (for example, by properly conjugating a verb).
