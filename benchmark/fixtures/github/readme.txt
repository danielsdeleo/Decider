The GitHub Contest
==================

This is the data for the GitHub contest (contest.github.com).  The 
goal of this contest is to figure out how to recommend repositories 
that users will want to watch given which repositories they are already
watching.

Your solution must be open sourced under an OSI approved license at the 
end of the contest and your result files must be pushed to our servers 
by noon PST on August 30st 2009..

We are doing this as a contest so that GitHub itself can be improved for 
open source users, but also so that these recommendation algorithms will
be available in one place for everyone to use.  We feel that our problem
is very similar to what many commercial sites have - generating high quality
recommendations based on past binary explicit choices and that open source
code to solve this problem will help improve a lot of sites.

These datasets are public domain - you may use them for whatever you wish.

The files in this download are as follows:

## data.txt ##

This is the main dataset.  Each line is of the format <user_id>:<repo_id>
which represents a user watching a repository.  There are 440,237 records
in this file, each a single user id and a single repository id seperated
by a colon.  The data looks something like this:

  43642:123344
  742:22132
  5414:2373
  8660:1160
  10218:409
  301:6979

## repos.txt ##

This file lists out the 120,867 repositories that are used in the data.txt
set, providing the repository name, date it was created and (if applicable)
the repository id that it was forked off of.  The data looks like this:

  123335:seivan/portfolio_python,2009-02-18
  123336:sikanrong/Nautilus-OGL,2009-05-19
  123337:edlebowitz/Downloads,2009-05-05
  123338:DylanFM/roro-faces,2009-05-31,13635
  123339:amazingsyco/technicolor-networking,2008-11-22
  123340:netzpirat/radiant-scoped-admin-extension,2009-02-27,53611
  123341:panchenliang/tuxedo-bank-server,2009-05-19

## lang.txt ##

The last dataset included is the language breakdown data.  This lists the
languages we could identify in each repository - only 73,496 repositories
have language data that we have calculated, but it is data available to us
so if you want to use it for classifications or something, feel free. Each
line of this file lists the repository id, then a comma delimited list of 
"<lang>;<lines>" entries containing each major language found and the number
of lines of code for that language in the project.  The data looks like this:

  57493:C;29382
  73920:JavaScript;9759,ActionScript;12781
  106774:Perl;4449
  123201:JavaScript;148,Ruby;16079
  65707:Ruby;29998
  98561:JavaScript;217,Ruby;4800900

## test.txt ##

Finally, we have the test file.  This file lists out 4,788 user ids from the
data.txt file.  Your job in the contest is to guess up to 10 repository ids
that each user might be interested in.  The data looks like this:

  55640
  55670
  55879
  56215
  56230

## The Goal ##

Your goal is to output a 'results.txt' file that has one line for each user
id in the 'test.txt' file, followed by a colon and a comma delimited list of
up to 10 repository ids that you recommend.  The final 'results.txt' file 
that you include in your entry repository should look something like this:

  9812:17,654,1119,302,84,755,616,58,8,518
  27373:1065,17,8,302,616,518,245,301,58,84
  19626:17,354,81,76,654,302,650,138,564,301
  44418:18963,17456,873,93806,372,46610,56884,1389,10486,542

There should be up to 4,788 lines in that file.  Commit it with the code used
to generate it and push your repository to a GitHub project that has 
'http://contest.github.com' as a post-receive hook for us to find and grade 
your entry.

See http://github.com/schacon/test-entry for an example.

