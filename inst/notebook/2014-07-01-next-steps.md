# Next steps for pubtime

## Agenda:

8AM Califonia / 4 PM London, Weds July 2.

Noam, Alex, Ross

-  Outputs/Goals
-  Journal Coverage
-  Timeline/Logistics
-  Questions/Analyses
-  Other

## Outputs/Goals

I envinsion the output as a single manuscript, but we can have a series of blog
posts as we complete individual analyses.  The R package containing all the
scraping code, as well as the completed data set, will also be public.

## Journals

We currently have tested the scraper on:

-   The Condor
-   Ecology
-   Ecological Applications
-   Ecological Monographs
-   Ecosphere
-   PeerJ (Ecology topic)
-   PLoS Journals (Ecology topic)
-   Proceedings of the Royal Society B: Biological Sciences
-   Biology Letters
-   Ecology Letters
-   Journal of Ecology
-   American Naturalist
-   Ecosystems
-   Theoretical Ecology

We've chosen to focus on major journals in Ecology. What else do we want to cover 
(and which shouldn't we bother with)? *The Condor* and *Theoretical Ecology* are
somewhat specialized. *Oikos* doesn't provide publication history, though 
*Oecologia* (Springer) does.

- I think we should use some existing list (top _n_ journals ranked by impact factor / Eigenfactor?); *The Condor* is a pretty specialized journal, and it would be unfair to single it out with broader ecology journals. An analysis of ornithological journal (where there are >20) could be something down the road. -Alex

Anything from Wiley, JSTOR, Springer, or BioOne is pretty easy.  Elsevier/ScienceDirect
is harder due to their website structure, though possible in the slightly
longer term as [Quickscrape](https://github.com/ContentMine/quickscrape) adopts
some features we need.

I think we should scrape complete years 2004-2013, though for many journals the
data won't go back that far. 

## Timing and Logistics

We can approximate ~10 seconds/article, though in many cases it will be faster
as we scrape separate jourals simultaneously. This will end up adding up to
several days.  If it's more convenient, we can break it up into runs.

We've already run some tests, but it makes sense to run more.  I can provide
some scripts, which will include first a sub-sample of articles and then the whole
shebang.

I'd like to start in the next couple of days if possible.

## Analyses

Some questions/analyses:

-   How do journals compare in average/median review times?
-   How do journals compare in time from acceptance to first availability
    of a paper online?
-   How do the *distributions* of review times differ among journals?
    -   How are the distributions different between journals that have "reject
        and resubmit options" and those that don't?
    -   Can we detect abnormally short review times that we think are associated
        with "reject and resubmit"?
        -   Hypothesis: Journals with these will have bi-model distributions
            with a peak of very short review times.
-   Have review times changed over time?
    -   See [this post](http://geokook.wordpress.com/2014/07/01/time-to-accept-it-publishing-in-the-journal-of-statistical-software/)
        on review times in JSS for one appraoch to this?
-   What's the papers among papers? How is the editor load distributed?
-   How much of variance in review times is attribtable to editors?

A good framework for the last quesion is a Cox proportional
hazards model, treating time-to-accept or time-to-publish as a survival time.
The `coxme` package allows such modeling with mixed effects, so we could
specify editor as a random effect and see how much variance is explained by
editors in each journal.

- Some other resources:
    - [An analysis of review times in statistical journals (PDF)](http://www.biometrics.tibs.org/carroll.pdf)
    - [Revise and resubmit rates at top philosophy journals](http://www.andrewcullison.com/2009/09/revise-and-resubmit-rates-at-top-philosophy-journals/); more [here](http://www.andrewcullison.com/2009/09/journal-review-time-comparisons/)
    - [A *very* old look at computer science journals](http://www.hutter1.net/journals.htm)
    - [A blog post on medical journals, but without any actual data](http://sharmanedit.wordpress.com/2012/06/13/acceptance-to-publication-time/)

- Journal articles concerning review times
    - [How Long is the Peer Review Process for Journal Manuscripts? A Case Study on _Angewandte Chemie International Edition_ (PDF)](http://www.lutz-bornmann.de/icons/TimePeerReview5.pdf)
    - [A Three-Decade History of the Duration of Peer Review](http://utpjournals.metapress.com/content/m652x27055h232l1/?genre=article&id=doi%3a10.3138%2fjsp.44.3.001)
    - [The publishing delay in scholarly peer-reviewed journals](http://www.sciencedirect.com/science/article/pii/S1751157713000734)
    - [Editorial responsiveness, journal quality, and total review time: An empirical analysis](http://onlinelibrary.wiley.com/doi/10.1002/asi.22624/abstract;jsessionid=A1440466E600A3BEC66A05A13A032C90.f03t01)
    - [Behind the shroud: a survey of editors in ecology and evolution](http://www.esajournals.org/doi/abs/10.1890/090048)
    - [Peer review time: how late is late in a small medical journal?](http://www.arcmedres.com/article/S0188-4409(03)00097-3/abstract)

## Other

**Question for Ross:** You mentioned the importance of stating the noncommerical
nature of the work for purposes of UK law. Does this mean we should make
everything we put out CC-BY-NC?
