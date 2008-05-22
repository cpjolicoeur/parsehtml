class ParseHTML #:nodoc:
  
  # tags which are always empty (<br />, etc.)
  EMPTY_TAGS = %w(br hr input img)
  
  # tags with preformatted text - whitespace won't be touched in them
  PREFORMATTED_TAGS = %w(script style pre code)
  
  # list of block elements
  # - tag_name => bool (is block level)
  BLOCK_ELEMENTS = {'address' => true,
                		'blockquote' => true,
                		'center' => true,
                		'del' => true,
                		'dir' => true,
                		'div' => true,
                		'dl' => true,
                		'fieldset' => true,
                		'form' => true,
                		'h1' => true,
                		'h2' => true,
                		'h3' => true,
                		'h4' => true,
                		'h5' => true,
                		'h6' => true,
                		'hr' => true,
                		'ins' => true,
                		'isindex' => true,
                		'menu' => true,
                		'noframes' => true,
                		'noscript' => true,
                		'ol' => true,
                		'p' => true,
                		'pre' => true,
                		'table' => true,
                		'ul' => true,
                		# set table elements and list items to block as well
                		'thead' => true,
                		'tbody' => true,
                		'tfoot' => true,
                		'td' => true,
                		'tr' => true,
                		'th' => true,
                		'li' => true,
                		'dd' => true,
                		'dt' => true,
                		# header items and html / body as well
                		'html' => true,
                		'body' => true,
                		'head' => true,
                		'meta' => true,
                		'style' => true,
                		'title' => true,
                		# inline elements
                		'a' => false,
                		'abbr' => false,
                		'acronym' => false,
                		'applet' => false,
                		'b' => false,
                		'basefont' => false,
                		'bdo' => false,
                		'big' => false,
                		'br' => false,
                		'button' => false,
                		'cite' => false,
                		'code' => false,
                		'del' => false,
                		'dfn' => false,
                		'em' => false,
                		'font' => false,
                		'i' => false,
                		'img' => false,
                		'ins' => false,
                		'input' => false,
                		'iframe' => false,
                		'kbd' => false,
                		'label' => false,
                		'map' => false,
                		'object' => false,
                		'q' => false,
                		'samp' => false,
                		'script' => false,
                		'select' => false,
                		'small' => false,
                		'span' => false,
                		'strong' => false,
                		'sub' => false,
                		'sup' => false,
                		'textarea' => false,
                		'tt' => false,
                		'var' => false}
  
  # html to be parsed
  attr_accessor :html
  
  # node type:
  # - tag (see isStartTag)
  # - text (include cdata)
  # - comment
  # - doctype
  # - pi (processing instruction)
  attr_accessor :node_type
  
  # current node context
  # - either a simple string (text node) or something like
  # - <tag attrib="value"...>
  attr_reader :node
  
  # whether the current node is an opening tag (<a>) or not (</a>)
  # - set to nil if current node is not a tag
  # - NOTE: empty tags (<br />) set this to true as well!
  attr_reader :is_start_tag
  
  # whether current node is an empty tag (<br />) or not (<a></a>)
  attr_reader :is_empty_tag
  
  # tag name
  attr_reader :tag_name
  
  # attributes of current_tag (in hash)
  attr_reader :tag_attributes
  
  # whether the current tag is a block level element
  attr_reader :is_block_element
  
  # keep whitespace formatting
  attr_reader :keep_whitespace
  
  # list of open tags (array)
  # - count this to get current depth
  attr_accessor :open_tags
  

  def initialize(html = '')
    @html = html
    @open_tags = []
    @keep_whitespace = 0
    @is_block_element = nil
    @tag_attributes = nil
    @tag_name = ''
    @is_empty_tag = nil
    @is_start_tag = nil
    @node = ''
    @node_type ''
  end
  
  # get next node
  def next_node
    return false if @html.blank?

    skip_whitespace = true
    if (@is_start_tag && !@is_empty_tag)
      @open_tags << @tag_name
      @keep_whitespace += 1 if @preformatted_tags.include?(@tag_name)
    end
    
    if (@html[0,1] == '<')
      token = html[0,9]
      if (token[0,2] == '<?')
        # xml, prolog, or other pi's
        # TODO: trigger error (this might need some work)
        pos = @html.index('>')
        set_node('pi', pos+1)
        return true;
      end
    end
  end # end next_node
  
  # update all variables and make @html shorter
  # - param type => @nodeType
  # - param pos  => which position to cut at
  def set_node(type, pos)
    if @node_type == 'tag'
      # set specific tag vars to null
      # type == tag should not be called here
      # see parse_tag for more info
      @tag_name = nil
      @tag_attributes = nil
      @is_start_tag = nil
      @is_empty_tag = nil
      @is_block_element = nil
    end
    @node_type = type
    @node = @html[0, pos]
    @html = @html[pos, @html.size-pos]
  end # end set_node
  
end # end class