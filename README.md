Hold Me, I'm a book
=======

Since the age of three, I've been an active patron of the San Francisco Public Library (SFPL). 
Using the SFPL catalog, though, can be a bit of a pain.

[Take this for example.](https://sflib1.sfpl.org/search~S1/?searchtype=X&searcharg=%22smitten+kitchen%22&searchscope=1&sortdropdown=-&SORT=D&extended=0&SUBMIT=Search)

To determine whether this book is available now, you must click through
to another page. 

I wanted to speed up the process between querying the catalog and requesting a hold. With Hold Me, a user can search for a book, keyword,
or author and see the availability of returned titles--all on one page.

A query returns the results from the catalog: the titles and their respective hold information
(# of holds and # of copies). These results include ebooks from the ebook platorms Axis360 and OverDrive.

Because OverDrive makes its API available only to institutional partners, I retrieve the hold information for 
each ebook with a script that scrapes the OverDrive ebook page. The script also scrapes Axis360 for availability of books
on that platform.