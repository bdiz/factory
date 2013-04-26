
require 'factory/version'

# The Factory mixin provides a robust Factory implementation. Overrides are
# automatically registered upon sub-classing. Manual override and disables are 
# available if auto-registration does not result in the desired factory overrides.
# Manual overrides are available at the class and global granularities. Method arguments
# can be passed in as strings or symbols so that overrides can be set even before 
# classes have been defined.
module Factory

	@override_lists = {}
	@global_override_disables = []

	# OverrideList is used to keep track of a classes various override settings.
	class OverrideList #:nodoc:

		attr_reader :class_name, :parent

		def initialize name
			@class_name = name
			@parent = nil
			@sub_class_overrides = []
			@override_disables = []
			@manual_overrides =[]
		end

		# Used to specify the parent class of the class which this OverrideList is for.
		def parent= class_name
			if (!@parent.nil? and !class_name.nil?) and (@parent != class_name)
				raise "parent can be written only once." 
			end
			@parent ||= class_name
		end

		# Called by Factory when a registered class is inherited from.
		def add_inherited_override sub_class
			@sub_class_overrides << sub_class
		end

		# Called by Factory when the user is manually overriding factory override 
		# sub-class defaults.
		def add_override name
			@manual_overrides << name
			@override_disables.delete name
		end

		# Called by Factory when the user is manually overriding factory override 
		# sub-class defaults.
		def remove_override name
			@override_disables << name
		end

		# Calculates and returns the class name as string of the factory override for the
		# class which this OverrideList is for. Manual and global overrides take 
		# presedence over automatic overrides via inheritance.
		def get_override
			overrides = @sub_class_overrides + @manual_overrides
			while !overrides.empty?
				override = overrides.pop
				return override unless @override_disables.include? override or 
												Factory.global_override_disables.include? override
			end
			return @class_name
		end

		# Called during testing.
		def reset_overrides #:nodoc:
			@manual_overrides.clear
			@override_disables.clear
		end

		# Returns a print friendly string which summarizes the factory override
		# configuration.
		def to_s
			<<-TXT
Factory Class: #{class_name}
  Parent:                   #{parent.nil? ? 'Not in Factory' : parent}
  Sub-class Overrides:      #{@sub_class_overrides.empty? ?
										'None' : @sub_class_overrides.join(', ')}
  Manual Overrides:         #{@manual_overrides.empty? ?
  										'None' : @manual_overrides.join(', ')}
  Manual Override Disables: #{@override_disables.empty? ? 
  										'None' : @override_disables.join(', ')}
  Factory Override:         #{get_override}
			TXT
		end

	end

	########################################
	# Factory Class Methods
	########################################
	
	# Include callback which adds class methods to the including class.
	def self.included klass #:nodoc:
		Factory.create_override_list klass
		klass.extend Factory::ClassMethods
	end

	# The methods in this module will be added to classes which include Factory as
	# class methods.
	module ClassMethods

		# Inheritance callback. Creates an OverrideList and adds sub-class auto-overrides.
		def inherited sub_class #:nodoc:
			Factory.create_override_list sub_class, self
			Factory.inherited_override self, sub_class
		end

		# Used to create objects of the type registered as the classes factory override.
		def create *args
			return Factory[self].new() if args.empty?
			return Factory[self].new(*args)
		end

		# Used to manually enable class specific override class.
		def enable_factory_override overriding_class
			Factory.enable_override self, overriding_class
		end

		# Used to manually disable class specific override class.
		def disable_factory_override overriding_class
			Factory.disable_override self, overriding_class
		end

		# Accessor which returns the class which is registered as this classes override.
		def factory_override
			Factory[self]
		end

	end
	
	########################################
	# Class Method Mixins
	########################################
	
	# Registers a class in the factory by creating it an OverrideList.
	def self.create_override_list klass, parent=nil #:nodoc:
		parent = parent.to_s unless parent.nil?
		@override_lists[klass.to_s] ||= OverrideList.new(klass.to_s)
		@override_lists[klass.to_s].parent ||= parent
		return @override_lists[klass.to_s]
	end

	# Adds inherited overrides up the chain of ancestors.
	def self.inherited_override parent, sub_class #:nodoc:
		override_list = @override_lists[parent.to_s]
		override_list.add_inherited_override sub_class.to_s
		if override_list.parent
			Factory.inherited_override override_list.parent, sub_class.to_s
		end
	end

	# Returns an OverrideList for +klass+ or creates it if it does not already exist.
	def self.override_list klass #:nodoc:
		@override_lists[klass.to_s] ||= Factory.create_override_list(klass.to_s)
	end

	# Accessor which returns the +@global_override_disables+ array.
	def self.global_override_disables #:nodoc:
		@global_override_disables.dup
	end

	# Used for testing purposes. Resets all manual override arrays. 
	def self.reset_overrides #:nodoc:
		@global_override_disables.clear
		@override_lists.each_value do |ovr_list|
			ovr_list.reset_overrides
		end
	end

	# Used to manually enable class specific override class.
	def self.enable_override overridden_class, overriding_class
		Factory.override_list(overridden_class).add_override overriding_class.to_s
	end
	
	# Used to manually disable class specific override class.
	def self.disable_override overridden_class, overriding_class
		Factory.override_list(overridden_class.to_s).remove_override overriding_class.to_s
	end

	# Used to manually disable a class from overriding any ancestors.
	def self.global_disable_override overriding_class
		@global_override_disables << overriding_class.to_s
	end

	# Used to cancel a previous +global_disable_override+.
	def self.remove_global_disable_override overriding_class
		@global_override_disables.delete overriding_class.to_s
	end

	# Accessor which returns the factory override of +base_class+.
	def self.[] base_class
		if @override_lists[base_class.to_s].nil?
			raise "class called #{base_class} is not registered with the factory."
		end
		eval @override_lists[base_class.to_s].get_override 
	end

	# Prints a summary of the Factory override configuration. Returns the summary as
	# a string. The summary will not be printed if +silent+ is true.
	def self.print_overrides silent=false
		s = <<-TXT
********************************
 Factory Overrides
********************************

Global Factory Override Disables: #{@global_override_disables.empty? ?
				'None' : @global_override_disables.join(', ')}

			TXT

		@override_lists.each_value {|ovr_list| s += ovr_list.to_s }
		puts s unless silent

		return s

	end

	########################################
	# Instance Method Mixins
	########################################
	
	# None.

end

