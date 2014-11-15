Hold Me, I'm a book
=======

I've been an active patron of the San Francisco Public Library (SFPL) since 1989. The SFPL online catalog is vital to me and other rogue researchers. Using it, though, can be a bit of a pain.

[Take this for example.](https://sflib1.sfpl.org/search~S1/?searchtype=X&searcharg=%22smitten+kitchen%22&searchscope=1&sortdropdown=-&SORT=D&extended=0&SUBMIT=Search)

To determine whether this book is available now, you must click on multiple "Is this available?" buttons that take you to another page.

I wanted to speed up the process between querying the catalog and requesting a hold. With Hold Me, a user can search for a book, keyword,
or author and view the availability of titles in the search results--all on one page.

A query returns the results from the catalog: the titles and their respective hold information (e.g.,
the number of copies the library owns and the number of holds on the copies).
These results include ebooks from the ebook platforms Axis360 and OverDrive. Because OverDrive and Axis360 makes their APIs available 
only to institutional partners, I retrieve the hold information for 
an ebook by scraping OverDrive or Axis360, depending on where the book is.

### Installation

Run <code>git clone</code> https://github.com/kariannemah/hold-me.git to clone this repository to your local machine.

Run <code>cd hold-me</code> to move into the cloned repo. Then, run <code>bundle install</code> to install required gems.

Run the application on your local server with <code>ruby app.rb</code>.

Visit http://localhost:4567 to view the application.
