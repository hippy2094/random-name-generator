Random name list generator
(c)2017 Matthew Hipkin <http://www.matthewhipkin.co.uk>


Creates an XML file containing a list of random names and ages up to the value
specified in TOTALCOUNT (line 10).

Requires fpc <http://www.frepascal.org> to build and for both firstnames.txt 
and surnames.txt to be in the same directory.

The name parts were taken from http://homepage.net/name_generator/

Building

After installing FreePascal, simply run the following command to build:

# fpc createnameslist.pas

Then execute the created createnameslist[.exe] binary, optionally specifying
the number of names to be generated:

# ./createnameslist 3

Example output:

<?xml version="1.0" encoding="UTF-8" ?>
<people>
  <person>
    <firstname>Leonard</firstname>
    <surname>Walker</surname>
    <age>68</age>
  </person>
  <person>
    <firstname>Lisa</firstname>
    <surname>Paterson</surname>
    <age>51</age>
  </person>
  <person>
    <firstname>Christopher</firstname>
    <surname>Harris</surname>
    <age>7</age>
  </person>
</people>

