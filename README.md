TODO:
For ebooks
  if holds == 1, make it 'hold'
  if copies == 1, make it 'copies'

Speed it up. Right now it's very slow, what with ALL the LOOPING!!




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
