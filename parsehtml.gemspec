Gem::Specification.new do |s|
  s.name = "parsehtml"
  s.version = "0.5.1"
  s.date = "2008-11-25"
  s.summary = "ParseHTML is an HTML parser which works with Ruby 1.8 and above."
  s.email = "cpjolicoeur@gmail.com"
  s.homepage = "http://github.com/cpjolicoeur/parsehtml"
  s.description = "ParseHTML is an HTML parser which works with Ruby 1.8 and above. ParseHTML will even try to handle invalid HTML to some degree."
  s.has_rdoc = true
  s.authors = ["Craig P Jolicoeur"]
  s.files = FileList['lib/*.rb', 'test/*'].to_a
  s.test_files = FileList['test/*'].to_a 
end
