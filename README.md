# budgetTools
Created 12.07.2015 by David Martino 

This R script provides tools to analyse yearly transaction statement logs from your bank

it has been adapted from an original post https://benjaminlmoore.wordpress.com/2014/01/04/analyse-your-bank-statements-using-r/

The input is a .csv file of transcations for the financial year downloaded from your bank online

The file is read into R and oragnised into a 3-column table containing these fields:

Date
Value
Description

The most important stage of processing your transaction log is to classify each one into some meaningful group. 
A single line in your transaction file may look like this:

07/01/2013,POS,"'0000 06JAN13 , SAINSBURYS S/MKTS , J GROATS GB",-15.90,600.00,"'BOND J","'XXXXXX-XXXXXXXX",

Given the headers above, we can see that most of the useful information is contained within the quoted Description field, 
which is also full of junk. To get at the good stuff we need the power of regular expressions (regexp), 
but thankfully some pretty simple ones.

In fact, given the diversity of labels in the description field, 
our regular expressions end up essentially as lists of related terms. 
For example, maybe we want to group cash machine withdrawals; 
by inspecting the description fields we can pick out some useful words, 
in this case bank names like NATWEST, BARCLAYS and CO-OPERATIVE BANK. 
Our “cash withdrawal” regexp could then be:

"NATWEST|BARCLAYS|BANK"
And we can test this on our data to make sure only relevant rows are captured:

s[grepl("NATWEST|BARCLAYS|BANK", s$desc),]
Now you can rinse and repeat this strategy for any and all meaningful classes you can think of.

The table is aggregated into transactions by month and plotted using ggplot to visualise the values and trends over the year.
