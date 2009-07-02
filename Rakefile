require 'rake'
require 'rake/clean'
require 'rake/rdoctask'

require 'fileutils'
include FileUtils

NAME = "My Module"
VERS = ENV['VERSION'] || "1.0.0"
CLEAN.include ['**/.*.sw?', '*.gem', '.config', 'test/test.log']

RDOC_OPTS = ['--quiet', '--title', "My Module, the Documentation",
    "--opname", "index.html",
    "--line-numbers",
    "--main", "README",
    "--inline-source"]

task :doc => [:rdoc]

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.template = "extra/iphone_rdoc.rb"
    rdoc.main = "README"
    rdoc.title = "My Module, the Documentation"
    rdoc.rdoc_files.add ['README', 'AUTHORS', 'COPYING', "ChangeLog",
      'extra/iphone_rdoc.rb']
end
