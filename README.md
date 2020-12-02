# EconoLingual

Recent work in the field of [multilingual translation](https://www.doviak.net/pages/ml-sicilian/ml-scn_p06.shtml) has shown that it's possible to train a neural machine translation model that can translate from any language to any language.

So now that we know how to do it, let's do it!  Let's use multilingual translation to share our work with others all around the world.

What would it take to develop a multilingual translator for the field of Economics?  Certainly some translated economics text, like the ones from the [European Central Bank](http://opus.nlpl.eu/ECB.php).  But to be worthy of the "multilingual" name, we'll also need non-European language text.

Where can we obtain that text?  How do we incorporate it into our dataset?  And how do we use it to train a multilingual translation model?  Those are the questions that we'll explore in this repository.


##  Roadmap

Let's begin by breaking the product into its two component pieces:  the multilingual translator and the economics translator.

We first need to practice multilingual translation, so that we know how to avoid its pitfalls of multilingual translation, like _off-target translation_ (i.e. translating into the wrong language).  We also need to practice working with different character sets, tokenizations and subword splitting.

And we need to practice economics translation.  Some languages will not have a fully developed economics vocabulary.  In those cases, we will have to create it, so we should also consider simultaneous development of a multilingual economics dictionary.


##  Subword Splitting

While developing [_Tradutturi Sicilianu_](https://translate.napizia.com), we obtained large improvements in translation quality by biasing the learned [subword vocabulary](https://www.doviak.net/pages/ml-sicilian/ml-scn_p04.shtml) towards the desinences one finds in a textbook.

Specifically, we added a unique list of words and the inflections of verbs, nouns and adjectives to the Sicilian data when learning the [byte-pair encoding](https://github.com/rsennrich/subword-nmt).  Because each word was only added once, none of them affected the distribution of whole words.  But once the words were split, they greatly affected the distribution of subwords, filling it with stems and suffixes.

And because the resulting subword vocabulary is similar to the theoretical stems and desinences of a textbook, the machine learned to translate in a more theoretical way (for example, by properly conjugating a verb).



