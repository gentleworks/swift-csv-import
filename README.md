# swift-csv-import
Quick and dirty csv parser in Swift

There's nothing elegant about this, but the data I'm reading is pretty ugly, too.  Inspired by https://makeapppie.com/2016/05/30/how-to-read-csv-files-from-the-web-in-swift/, but shares little code with it.

Use this at your own risk; maybe it'll help if you find yourself with import data that chokes the more formal csv libraries like I did.

Caveats:
* This library was used in iOS development, so it imports UIKit in order to get some file handling access.  Switch to whatever you need.
* Code is Swift 4 compliant and hasn't been tested with version 5, but changes, if any, should be minor, since it uses very basic functions.
* The parser was built to handle bad Excel-style csv exports, so expects the Microsoft flavor of csv, with quoted fields and embedded unescaped line breaks.
* The pipe (|) character is substituted for internal line breaks during parsing.  If you need to preserve pipes in your incoming data, you will need to update this to some other unique token (probably as easy as find-and-replace all the pipes in the code).  If I was nicer, I'd find-and-replace with a constant string and set it at the top, but instead it's left as an exercise for the reader.
