$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'factory'
require 'minitest/autorun'
require 'minitest/spec'

Factory.enable_override :Base, :C3
Factory.global_disable_override :C4
class Base
	include Factory
	attr_reader :arg
	def initialize arg=nil
		@arg = arg
	end
end

class C1 < Base
	include Factory # Not needed but shouldn't hurt anything
end
C1.disable_factory_override :C5
class C2 < Base
end
class C3 < C1
end
class C4 < C2
end
class C5 < C1
end
Array.class_eval do
	include Factory
end
class Array2 < Array
end
