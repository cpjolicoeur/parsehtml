#
# Version 1.12 - Aug 20, 2008
#

class ParseHTML #:nodoc:
  
  # tags which are always empty (<br />, etc.)
  EMPTY_TAGS = %w(br hr input img area link meta param)
  
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
                		'link' => true,
                		'style' => true,
                		'title' => true,
                		# media tags to render as block
                		'map' => true,
                		'object' => true,
                		'param' => true,
                		'embed' => true,
                		'area' => true,
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
  attr_reader :node_type
  
  # current node context
  # - either a simple string (text node) or something like
  # - <tag attrib="value"...>
  attr_accessor :node
  
  # supress HTML tags inside preformatted tags
  attr_accessor :no_tags_in_code
  
  # whether the current node is an opening tag (<a>) or not (</a>)
  # - set to nil if current node is not a tag
  # - NOTE: empty tags (<br />) set this to true as well!
  attr_reader :is_start_tag
  
  # whether current node is an empty tag (<br />) or not (<a></a>)
  attr_reader :is_empty_tag
  
  # whether the current tag is a block level element
  attr_reader :is_block_element
  
  # tag name
  attr_reader :tag_name
  
  # attributes of current_tag (in hash)
  attr_reader :tag_attributes
  
  # keep whitespace formatting
  attr_reader :keep_whitespace
  
  # list of open tags (array)
  # - count this to get current depth
  attr_reader :open_tags
  

  def initialize(html = '')
    @html = html
    @open_tags = []
    @node_type, @node, @tag_name = '', '', ''
    @is_start_tag, @is_empty_tag, @is_block_element, @no_tags_in_code = false, false, false, false
    @tag_attributes = nil
    @keep_whitespace = 0
  end
  
  # get next node
  def next_node
    return false if (@html.nil? || @html.empty?)

    skip_whitespace = true # FIXME: should probably be a class variable?
    if (@is_start_tag && !@is_empty_tag)
      @open_tags << @tag_name
      @keep_whitespace += 1 if PREFORMATTED_TAGS.include?(@tag_name)
    end
    
    if (@html[0,1] == '<')
      token = html[0,9]
      if (token[0,2] == '<?')
        # xml, prolog, or other pi's
        # TODO: trigger error (this might need some work)
        pos = @html.index('>')
        set_node('pi', pos+1)
        return true;
      end # end pi tag
      if (token[0,4] == '<!--')
        # HTML comment
        pos = @html.index('-->')
        if pos.nil?
          # could not find a closing -->, use next gt tag instead
          # this is what firefox does with its parsing
          pos = @html.index('>') + 1
        else
          pos += 3
        end
        set_node('comment', pos)
        return true
      end # end comment tag
      if (token == '<!DOCTYPE')
        # doctype
        set_node('doctype', @html.index('>')+1)
        @skip_whitespace = true
        return true
      end # end <!DOCTYPE tag
      if (token == '<![CDATA[')
        # cdata, use text mode
        
        # remove leading <![CDATA[
        @html = @html[9, @html.size-9]
        set_node('text', @html.index(']]>')+3)
        
        # remove trailing ]]> and trim
        @node = @node[0, -3]
        handle_whitespaces
        
        @skip_whitespace = true
        return true
      end # end cdata
      if (parse_tag)
        # seems to be a tag so handle whitespaces
        skip_whitespace = @is_block_element ? true : false
        return true
      end # end parse_tag
    end
    
    skip_whitespace = false if @keep_whitespace
    
    # when we get here it seems to be a text node
    pos = @html.index('<') || @html.size
    
    set_node('text', pos)
    handle_whitespaces
    return next_node if (skip_whitespace && @node == ' ')
    skip_whitespace = false
    return true
  end # end next_node
  
  # normalize self.node
  def normalize_node
    @node = '<'
    unless (@is_start_tag)
      @node << "/#{@tag_name}>"
      return
    end
    @node << @tag_name
    @tag_attributes.each do |name, value|
      str = " #{name}=\"" + value.gsub(/\"/, '&quot;') + "\""
      @node << str
    end
    @node << ' /' if (@is_empty_tag)
    @node << '>'
  end
  
  private
  
  # parse tag, set tag name and attributes, check for closing tag, etc...
  def parse_tag
    a_ord = ?a
    z_ord = ?z
    special_ords = [?:, ?-] # for xml:lang and http-equiv
    
    tag_name = ''
    pos = 1
    is_start_tag = (@html[pos,1] != '/')
    pos += 1 unless is_start_tag
    
    # get tag name
    while (@html[pos,1])
      char = @html.downcase[pos,1]
      pos_ord = char[0]
      if ((pos_ord >= a_ord && pos_ord <= z_ord) || (!tag_name.empty? && is_numeric?(char)))
        tag_name << char
        pos += 1
      else
        pos -= 1
        break
      end
    end # end while
    
    tag_name.downcase!
    if (tag_name.empty? || !BLOCK_ELEMENTS.include?(tag_name))
      # something went wrong, invalid tag
      invalid_tag
      return false
    end
    
    if (@no_tags_in_code && @open_tags.last == 'code' && !(tag_name == 'code' && !is_start_tag))
      # supress all HTML tags inside code tags
      invalid_tag
      return false
    end
    
    # get tag attributes
    # TODO: in HTML 4 attributes dont need to be quoted
    is_empty_tag = false
    attributes = {}
    curr_attribute = ''
    while (@html[pos+1,1])
      pos += 1
      # close tag
      if (@html[pos,1] == '>' || @html[pos,2] == '/>')
        if (@html[pos,1] == '/')
          is_empty_tag = true
          pos += 1
        end
        break 
      end

      char = @html.downcase[pos,1]
      pos_ord = char[0]
      if (pos_ord >= a_ord && pos_ord <= z_ord)
        # attribute name
        curr_attribute << char
      elsif ([' ', "\t", "\n"].include?(char))
        # drop whitespace
      elsif
        # get attribute value
        pos += 1
        await = @html[pos,1] # single or double quote
        pos += 1
        value = ''
        while (@html[pos,1] && @html[pos,1] != await)
          value << @html[pos,1]
          pos += 1
        end # end while
        attributes[curr_attribute] = value
        curr_attribute = ''
      else
        invalid_tag
        return false
      end
    end # end while
    
    if (@html[pos, 1] != '>')
      invalid_tag
      return false
    end
    
    if (!curr_attribute.empty?)
      # html4 allows something like <option selected> instead of <option selected="selected">
      attributes[curr_attribute] = curr_attribute
    end
    
    unless (is_start_tag)
      if (!attributes.empty? || (tag_name != @open_tags.last))
        # end tags must not contain any attributes
        # or maybe we did not expect a different tag to be closed
        invalid_tag
        return false
      end
      @open_tags.pop
      if (PREFORMATTED_TAGS.include?(tag_name))
        @keep_whitespace -= 1
      end
    end 
    pos += 1
    @node = @html[0,pos]
    @html = @html[pos, @html.size-pos]
    @tag_name = tag_name
    @tag_attributes = attributes
    @is_start_tag = is_start_tag
    @is_empty_tag = is_empty_tag || EMPTY_TAGS.include?(tag_name)
    if (@is_empty_tag)
      # might not be well formed
      @node.gsub!(/ *\/? *>$/, ' />')
    end
    @node_type = 'tag'
    @is_block_element = BLOCK_ELEMENTS[tag_name]
    return true
  end
  
  # handle invalid tags
  def invalid_tag
    @html = '&lt;' + @html.slice(1, @html.size - 1)
  end
  
  # update all variables and make @html shorter
  # - param type => @nodeType
  # - param pos  => which position to cut at
  def set_node(type, pos)
    if (@node_type == 'tag') # (type == 'tag')
      # set specific tag vars to null
      # type == tag should not be called here
      # see parse_tag for more info
      @tag_name = nil
      @tag_attributes = nil
      @is_start_tag = false
      @is_empty_tag = false
      @is_block_element = false
    end
    @node_type = type
    @node = @html[0, pos]
    @html = @html[pos, @html.size-pos]
  end # end set_node
  
  # check if @html begins with a specific string
  def match?(str)
    @html.slice(0, str.size) == str
  end
  
  # truncate whitespaces
  def handle_whitespaces
    return if (@keep_whitespace.nil? || @keep_whitespace.zero?)
    @node.gsub!(/\s+/, ' ')
  end
  
  # check if a string is a valid numeric value
  def is_numeric?(val)
    Float val rescue false
  end
  
  # indent HTML properly
  def self.indent_html(html, indent = '  ', no_tags_in_code = false)
    parser = ParseHTML.new(html)
    parser.no_tags_in_code = no_tags_in_code
    html = ''
    last = true # last tag was block element
    indent_a = []

    while (parser.next_node)
      parser.normalize_node if (parser.node_type == 'tag')
      if ((parser.node_type == 'tag') && parser.is_block_element)
        is_pre_or_code = ['code', 'pre'].include?(parser.tag_name)
        if(parser.keep_whitespace.zero? && !last && !is_pre_or_code)
          html = html.rstrip + "\n"
        end
        if (parser.is_start_tag)
          html << indent_a.join(' ')
          if (!parser.is_empty_tag)
            indent_a << indent
          end
        else
          indent_a.pop
          if (!is_pre_or_code)
            html << indent_a.join(' ')
          end
        end
        html << parser.node
        if (parser.keep_whitespace.zero? && !(is_pre_or_code && parser.is_start_tag))
          html << "\n"
        end
        last = true
      else
        if (parser.node_type == 'tag' && parser.tag_name == 'br')
          html << (parser.node + "\n")
          last = true
          next
        elsif (last && parser.keep_whitespace.zero?)
          html << indent_a.join(' ')
          parser.node = parser.node.lstrip
        end
        html << parser.node
        
        if (['comment', 'pi', 'doctype'].include?(parser.node_type))
          html << "\n"
        else
          last = false
        end
      end
    end # end while
    return html
  end
  
end # end class ParseHTML
