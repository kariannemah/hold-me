TODO:

using threads now. how do i determine if this is thread safe?

---------done----------
 add link to checkout the book - done
 if there is a null result, return the link to check out the book

 with Overdrive, Library Availability API - I scraped both overdrive and axis360 - done!

if the book is an electronic resource, open that URL
open "Get Axis360 link" or open Overdrive link - done!
check # of holds and # of available copies - done!

take into consideration there are 4 options for digital availability: - done!
1. overdrive
2. axis360
3. ebscoHost/safari tech (other ones too!)
4. serialssolutions - online periodicals


- new data structure: nested hash map
- removed reference to either overdrive or axis360
@books
   @urls
   @link_url
   @ebook_urls

For ebooks
  if holds == 1, make it 'hold' - done!
  if copies == 1, make it 'copies' - done!

pre-thread deliberation: - should I use a task manager? a queue? multiple workers?
or should I spawn a few threads-done!
search for IJ now takes 11s vs. 24s


Speed it up! it's very slow, what with ALL the LOOPING!!
-added two method, but write some other ones
-extract duplicate methods