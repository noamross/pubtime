Contributions are welcome! In addition to enhancements, code reviews and bug
reports, there are some main ways people can contribute to this project: *write
scrapers* and *scrape data*.

# Scrapers

The format for publication history dates varies by publisher to publisher and
even journal to journal.  So every journal needs needs its own *scraper 
function.*  A scraper function takes a DOI (as a string) and returns its publication
history as a list.  To contribute one, fork the repo and add a function in an `.R`
file in the `R/` directory.

The function has to do two main things

-  Get the page which has publication history.  Usually this is the DOI landing page, which can be grabbed
   with `GET(paste0("http://dx.doi.org/", doi))`, but for some publishers the
   publication history is on a different page, like something ending in `/info`.
-  Scrape that page for the publication history. These are the fields listed in
`?get_pub_history`.  Few journals will have them all. We want both the date values,
and the terms the journal uses for those dates (e.g., "Accepted Date").  

Where available, the scraper should also get the editor of the article, as a
string.
    
The function should return a list with all the dates and the editor as separate
elements.  The list should be named, using the terms the journal uses. Dates 
should be class `Date`, and the editor shoudl be a string.
    
I recommend using functions from `XML` and `stringi` packages for your scraper.  See
the existing functions in `R/scrapers.R` for examples.
  
Once you have written your scraper, we want to map the *journals'* terms for dates
onto our standard typology.  Look at `inst/journal_data/datenames.yaml`.  This file
contains the mapping.  If the terms your journal uses aren't in here, add them.

Now add a line to `inst/journal_data/journals.csv` for your journal.  The fields
are described in `?journals`.  This is where the wrapper function
`get_pub_history` looks.

Great!  Submit a pull request.  Or go ahead to the next step and submit after
you've collected data.

# Data

The point of scrapers is to get data!  But we can't just do it all at once.  Why?

-   The legality of scraping web pages for this purposes is murky and context-
    dependent.  Basically, depending on the publisher, its agreement with your
    univeristy, and your location, it may or may not be kosher.  To my understanding,
    this is totally OK in the UK. See [here](https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/315014/copyright-guidance-research.pdf). In the U.S., it depends on the terms of service
    on the publisher' website if the information is available on publicly available
    pages, and on your university's contract if the information is on subscription-
    only pages.
    
-   To prevent appearing like a DDoS attack or otherwise taxing publisher servers,
    we need to scrape information at a throttled rate, meaning it takes a lot of
    time.
    
So, to contribute data:

1.  Check that you are legally OK,
2.  Look at the `inst/get_journals_data.R` for an example of how to generate
    a dataset.  The function `get_dois()` generates a vector of DOIs for a journal
    over a range over a range of years.  Ideally we want the last 10 years or so.
    Then `scrape_dates()` collects the data and writes it to files. It has
    default throttling designed to keep you from getting your IP blocked.
3.  Write your scraping script, commenting heavily and including the date you run it.
    Note that with throttling it may take hours/days.
4.  Check the error log, which show DOIs where the scrapers failed.   Some DOIs
    fail because they are for articles without publication histories (e.g., errata). That's fine.
    But make sure you aren't missing real data.
4.  Put your script in `inst/` and the resulting data in `inst/journal_data`.
5.  Pull request!


# Check some data

The data need to be spot-checked.  Pick one of the data set and go through it
to look for scraping errors.  Modify the scraping scripts to adjust them.

Actually, one thing to do would be to write some tests that contributors could
run to check their scraper worked right or their data came out properly.

# Crunch some numbers

If you want to do an analyis, do it as narrative code and put it in
`inst/YYYY-MM-DD-some-analyses.Rmd`.  Be sure to put your name in the YAML
metadata.  Include the knitted `.md` file as well so that we can view the
results on github.  

These are probably exploratory blog-post length analyses.  Once we
have several we can collate them into a manuscript.

# Website

Depending on how far this project goes, it may be worthwhile to create
a website branch to display the data / post analyses.

# Authorship

If a publication comes out of this, we'll list co-authors as those who
contributed at least a data set or a major component of analysis/writing. Those
who contribute smaller patches will be in the awknowledgements. If you're
interested in authorship, it would be helpful if you let us know, either before
you start on a major analysis or with your pull request.
