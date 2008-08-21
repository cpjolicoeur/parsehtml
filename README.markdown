# ParseHTML

ParseHTML is an HTML parser which works with Ruby 1.8 and above.  ParseHTML will even try to handle invalid HTML to some degree

## Requirements

* Ruby 1.8 or above.

## Installation

Grab the source: http://github.com/cpjolicoeur/parsehtml

To install as a gem: coming soon

## Usage

`require 'parsehtml'`

`html = "<h1>This is my HTML code</h1>\n\n<p>Pass this <b>directly</b> into the parser</p>"`

Create a new parser object: 

`parser = ParseHTML.new(html)`

Traverse through the HTML nodes:

`parser.next_node`

## Developers

* [Craig P Jolicoeur](http://craigjolicoeur.com) - http://github.com/cpjolicoeur

## License

MIT License

Copyright (c) 2008 Craig P Jolicoeur

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Acknowledgments

ParseHTML is heavily based on the ParseHTML PHP library written by Milian Wolf (http://milianw.de).
