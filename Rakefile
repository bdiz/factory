require 'rake/testtask'
require 'rdoc/task'

#
# Rake defined tasks 
# 

Rake::TestTask.new do |t|
	t.libs << 'test'
	t.test_files = FileList['test/test*.rb']
#	t.verbose = true
end

Rake::RDocTask.new(:rdoc) do |rd|
	rd.main = "doc/README.rdoc"
	rd.rdoc_files.include("doc/*.rdoc", "lib/**/*.rb", "bin/*")
	rd.title = "Factory API"
	rd.options << "--include=doc"
end

Rake::RDocTask.new(:rdoc_dev) do |rd|
	rd.main = "doc/README.rdoc"
	rd.rdoc_files.include("doc/*.rdoc", "lib/**/*.rb", "test/**/*.rb", "bin/*")
	rd.rdoc_dir = "html_dev"
	rd.title = "Factory Development API"
	rd.options << "--all"
	rd.options << "--include=doc"
end

