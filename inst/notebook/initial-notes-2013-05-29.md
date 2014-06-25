---
title: "Initial Notes"
author: "Noam"
date: "May 29, 2014"
output: html_document
---

Some initial notes on a project to scrape and collect journal acceptance times.

-   Starting with Ecological Society of America Journals
-   Possible to do on the PLOS corpus
-   Want to break this out by editor, journal. Do publication times and 
    distributions vary by editor/journal? 
-   Hunting for oddly short time-to-acceptances to hunt for fake times.
-   Year of first submission should be encoded in the DOI ((10.1890/<08>-0874.1)
-   Likely fakes have short accept times, even more likely if DOI year does not
    match received year
-   Want to note we're not singling out ESA, maybe show to Don Strong for
    comment before posting? Maybe anonymize editors for 
    publication? 

---

Pseudocode for extracting ecology data

```
for journal, vol, issue, (working backwards)

journals = c("ecsp", "ecol", "emon", "ecap",)

read paste0("http://www.esajournals.org/toc/", journal, "/", vol, "/" issue)
            
function <- Extract all the links called "Abstract" e.g.,

  <a class="ref nowrap " href="/doi/abs/10.1890/12-1339.1">Abstract</a>

For all the links

function <- get data from abtract page

- Extract DOI from URL
  - Extract dates from the line like:
      Received: June 28, 2009; Revised: July 28, 2009; Accepted: July 29, 2009
      <p class="fulltext">Received: October 2, 2012; Revised: March 7, 2013; Accepted: March 12, 2013</p>
      
      (Note that more fields are possible.  Use regex to get all of them.
       Note that Monographs has a different field format, also has "published" field:
         
         Received 30 March 2010; revised 1 July 2010; accepted 19 July 2010; published 31 July 2010. OR
         <p class="first last"><b>Received</b> 30 March 2010; revised 1 July 2010; accepted 19 July 2010; <b>published</b> 31 July 2010.</p>

  - Extract corresponding editor:
      Corresponding Editor: M. H. Graham.

Progress bar should show Journal, Year

Break loop when no pages in an issue have recieved dates

Create data table. Journal, Vol, Issue, Editor, Extracted Revieved date (10.1890/<08>-0874.1), headers for all date fields
```

