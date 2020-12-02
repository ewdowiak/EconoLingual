# EconoLingual

Recent work in the field of [multilingual translation](https://www.doviak.net/pages/ml-sicilian/ml-scn_p06.shtml) has shown that it's possible to train a neural machine translation model that can translate from any language to any language.

So now that we know how to do it, let's do it!  Let's use multilingual translation to share our work with others all around the world.

What would it take to develop a multilingual translator for the field of Economics?  Certainly some translated economics text, like the ones from the [European Central Bank](http://opus.nlpl.eu/ECB.php).  But to be worthy of the "multilingual" name, we'll also need non-European language text.

Where can we obtain that text?  How do we incorporate it into our dataset?  And how do we use it to train a multilingual translation model?  Those are the questions that we'll explore in this repository.

##  Roadmap

Let's begin by breaking the product into its two component pieces:  the multilingual translator and the economics translator.

We first need to practice multilingual translation, so that we know how to avoid its pitfalls of multilingual translation, like _off-target translation_ (i.e. translating into the wrong language).

And we need to practice economics translation.  Some languages will not have a fully developed economics vocabulary.  In those cases, we will have to create it.

