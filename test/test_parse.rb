# test_parse.rb
# May 22, 2008
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'parsehtml'

@html = '<p>Simple block on one line:</p>

<div>foo</div>

<p>And nested without indentation:</p>

<div>
<div>
<div>
foo
</div>
<div style=">"/>
</div>
<div>bar</div>
</div>

<p>And with attributes:</p>

<div>
    <div id="foo">
    </div>
</div>

<p>This was broken in 1.0.2b7:</p>

<div class="inlinepage">
<div class="toggleableend">
foo
</div>
</div>'
#$html = '<a href="asdfasdf"       title=\'asdf\' foo="bar">asdf</a>';
puts ParseHTML.indent_html(@html);
