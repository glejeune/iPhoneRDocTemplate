require 'fileutils'

EXTRAS_DIR = File.expand_path(File.dirname(__FILE__))

module Generators
  class HTMLGenerator
    def generate_html
      @files_and_classes = {
        'allfiles'     => gen_into_index(@files),
        'allclasses'   => gen_into_index(@classes),
        'initial_page' => main_url,
        'realtitle'    => CGI.escapeHTML(@options.title),
        'charset'      => @options.charset
      }

      # the individual descriptions for files and classes
      gen_into(@files, RDoc::Page::FILE_INDEX, "files_index.html")
      gen_into(@classes, RDoc::Page::CLASS_INDEX, "classes_index.html")
      gen_main_index
      
      # this method is defined in the template file
      write_extra_pages if defined? write_extra_pages
    end

    def gen_into(list, tmpl, f)
      hsh = @files_and_classes.dup
      list.each do |item|
        if item.document_self
          op_file = item.path
          hsh['root'] = item.path.split("/").map { ".." }[1..-1].join("/")
          hsh['id'] = item.name.gsub( /[^a-zA-Z]/, "_" )
          item.instance_variable_set("@values", hsh)
          File.makedirs(File.dirname(op_file))
          File.open(op_file, "w") { |file| item.write_on(file) }
        end
      end
      
      template = TemplatePage.new(tmpl)
      File.open(f, "w") do |f|
        values = @files_and_classes.dup
        template.write_html_on(f, values)
      end
    end

    def gen_into_index(list)
      res = []
      list.each do |item|
        hsh = item.value_hash
        hsh['href'] = item.path
        hsh['name'] = item.index_name
        res << hsh
      end
      res
    end

    def gen_main_index
      template = TemplatePage.new(RDoc::Page::INDEX)
      File.open("index.html", "w") do |f|
        values = @files_and_classes.dup
        if @options.inline_source
          values['inline_source'] = true
        end
        template.write_html_on(f, values)
      end
      ipath = File.join(EXTRAS_DIR, "iui")
      FileUtils.cp_r ipath, "iui"
    end
  end
end

module RDoc
  module Page
    STYLE = %{}
    FONTS = %{}
    
    FILE_PAGE = %{
<div id="%id%" title="%title%" class="panel">
  %description%
</div>
}
    
    METHOD_LIST = %{ METHOD_LIST }
    
    CLASS_PAGE = %{ 
<div id="%id%" title="%title%" class="panel">
IF:requires
<h2>Requires:</h2>
<ul>
START:requires
  <li>%name%</li>
END:requires
</ul>
ENDIF:requires

IF:attributes
<h2>Attributes</h2>
<table>
START:attributes
<tr><td>%name%</td><td>%rw%</td><td>%a_desc%</td></tr>
END:attributes
</table>
ENDIF:attributes

IF:includes
<h2>Includes</h2>
<ul>
START:includes
  <li>%name%</li>
END:includes
</ul>
ENDIF:includes


START:sections
IF:method_list
<h2 class="ruled">Methods</h2>
START:method_list
IF:methods
START:methods
<ul>
  <li>
    %type% %category% method: 
IF:callseq
    <b>%callseq%</b>
ENDIF:callseq
IFNOT:callseq
    <b>%name%%params%</b>
ENDIF:callseq
  </li>
  <li>
IF:m_desc
    %m_desc%
ENDIF:m_desc
  </li>
</ul>
END:methods
ENDIF:methods
END:method_list
ENDIF:method_list
END:sections



</div>
}
    
BODY = %{
<!-- BEGIN: BODY -->
!INCLUDE!
<!-- BEGIN: BODY -->
}

CLASS_INDEX = %{
  <ul id="classes" title="Classes">
START:allclasses
    <li><a href="%href%">%name%</a></li>
END:allclasses
  </ul>
}

FILE_INDEX = %{
  <ul id="files" title="Files">
START:allfiles
    <li><a href="%href%">%name%</a></li>
END:allfiles
  </ul>
}

INDEX = %{
<!-- BEGIN: INDEX -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>%realtitle%</title>
    <meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
    <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
    <link rel="apple-touch-icon" href="iui/iui-logo-touch-icon.png" />
    <meta name="apple-touch-fullscreen" content="YES" />
    <style type="text/css" media="screen">@import "iui/iui.css";</style>
    <style type="text/css" media="screen">
      .panel > ul {
          position: relative;
          margin: 0 0 20px 0;
          padding: 0;
          background: #FFFFFF;
          -webkit-border-radius: 10px;
          -moz-border-radius: 10px;
          border: 1px solid #999999;
          font-size: 16px;
      }

      .panel > ul > li  {
          position: relative;
          list-style: none;
          padding: 14px 14px 14px 14px;
          border-bottom: 1px solid #999999;
          -webkit-border-radius: 0;
      }

      .panel > ul > li:last-child {
          border-bottom: none !important;
      }      
    </style>
    <script type="application/x-javascript" src="iui/iui.js"></script>
  </head>
  <body>
    <div class="toolbar">
      <h1 id="pageTitle"></h1>
      <a id="backButton" class="button" href="#"></a>
    </div>
  
    <ul id="home" title="%realtitle%" selected="true">
      <li><a href="%initial_page%">Read this first...</a></li>
      <li><a href="classes_index.html">Classes</a></li>
      <li><a href="files_index.html">Files</a></li>
  </body>
</html>
<!-- END  : INDEX -->
}

end
end
