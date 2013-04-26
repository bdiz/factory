
require 'helper'
require 'test/unit'

class FactoryTest < Test::Unit::TestCase

	def test_factory01_pre_class_definition_overrides

		assert_equal C3, Base.create.class
		assert_equal C3, Factory[Base]
		assert_equal C3, Base.factory_override

		assert_equal C2, C2.create.class
		assert_equal C2, Factory[C2]
		assert_equal C2, C2.factory_override

	end

	def test_factory02_check_inherited_overrides

		assert_equal C3, C1.create.class
		assert_equal C3, Factory[C1]
		assert_equal C3, C1.factory_override

		assert_equal C3, C3.create.class
		assert_equal C3, Factory[C3]
		assert_equal C3, C3.factory_override

		assert_equal Array2, Array.create.class
		assert_equal Array2, Factory[Array]

	end

	def test_factory03_enable_disable_factory_overrides
		Factory.reset_overrides

		# def enable_factory_override overriding_class
		# 	Factory.enable_override self, overriding_class
		# end

		# def disable_factory_override overriding_class
		# 	Factory.disable_override self, overriding_class
		# end

		C1.enable_factory_override C3

		assert_equal C5, Base.create.class
		assert_equal C5, Factory[Base]
		assert_equal C5, Base.factory_override
		assert_equal C3, C1.create.class
		assert_equal C3, Factory[C1]
		assert_equal C3, C1.factory_override
		assert_equal C3, C3.create.class
		assert_equal C3, Factory[C3]
		assert_equal C3, C3.factory_override
		assert_equal C5, C5.create.class
		assert_equal C5, Factory[C5]
		assert_equal C5, C5.factory_override

		C1.disable_factory_override C3
		Factory.disable_override :C1, C5
		C2.disable_factory_override :C4

		assert_equal C5, Base.create.class
		assert_equal C5, Factory[Base]
		assert_equal C5, Base.factory_override
		assert_equal C1, C1.create.class
		assert_equal C1, Factory[C1]
		assert_equal C1, C1.factory_override
		assert_equal C3, C3.create.class
		assert_equal C3, Factory[C3]
		assert_equal C3, C3.factory_override
		assert_equal C5, C5.create.class
		assert_equal C5, Factory[C5]
		assert_equal C5, C5.factory_override
		assert_equal C2, C2.create.class
		assert_equal C2, Factory[C2]
		assert_equal C2, C2.factory_override

		Factory.enable_override :Base, C1
		C3.enable_factory_override :C5
		Factory.enable_override "C1", "C3"

		assert_equal C1, Base.create.class
		assert_equal C1, Factory[Base]
		assert_equal C1, Base.factory_override
		assert_equal C3, C1.create.class
		assert_equal C3, Factory[C1]
		assert_equal C3, C1.factory_override
		assert_equal C5, C3.create.class
		assert_equal C5, Factory[C3]
		assert_equal C5, C3.factory_override
		assert_equal C5, C5.create.class
		assert_equal C5, Factory[C5]
		assert_equal C5, C5.factory_override

		Factory.disable_override :Array, Array2

		assert_equal Array, Array.create.class
		assert_equal Array, Factory[Array]

		Array.enable_factory_override Array2

		assert_equal Array2, Array.create.class
		assert_equal Array2, Factory[Array]

	end

	def test_factory05_global_disable_override_and_remove_global_disable_override
		Factory.reset_overrides

		Factory.global_disable_override :C4
		Factory.global_disable_override C5

		assert_equal C3, Base.create.class
		assert_equal C3, Factory[Base]
		assert_equal C3, Base.factory_override
		assert_equal C3, C1.create.class
		assert_equal C3, Factory[C1]
		assert_equal C3, C1.factory_override
		assert_equal C3, C3.create.class
		assert_equal C3, Factory[C3]
		assert_equal C3, C3.factory_override
		assert_equal C5, C5.create.class
		assert_equal C5, Factory[C5]
		assert_equal C5, C5.factory_override
		assert_equal C2, C2.create.class
		assert_equal C2, Factory[C2]
		assert_equal C2, C2.factory_override
		assert_equal C4, C4.create.class
		assert_equal C4, Factory[C4]
		assert_equal C4, C4.factory_override

		Factory.remove_global_disable_override C4

		assert_equal C4, Base.create.class
		assert_equal C4, Factory[Base]
		assert_equal C4, Base.factory_override
		assert_equal C3, C1.create.class
		assert_equal C3, Factory[C1]
		assert_equal C3, C1.factory_override
		assert_equal C3, C3.create.class
		assert_equal C3, Factory[C3]
		assert_equal C3, C3.factory_override
		assert_equal C5, C5.create.class
		assert_equal C5, Factory[C5]
		assert_equal C5, C5.factory_override
		assert_equal C4, C2.create.class
		assert_equal C4, Factory[C2]
		assert_equal C4, C2.factory_override
		assert_equal C4, C4.create.class
		assert_equal C4, Factory[C4]
		assert_equal C4, C4.factory_override

	end

	def test_factory06_create_args
		Factory.reset_overrides
		o = C1.create('hello')
		assert_equal C5, o.class
		assert_equal 'hello', o.arg
	end

	def test_factory07_print_overrides

		Factory.reset_overrides

		# One of each type of instance variable set
		Factory.global_disable_override :C4
		C1.enable_factory_override C3
		Factory.disable_override :Array, Array2

		expected_string = <<-TXT
********************************
 Factory Overrides
********************************

Global Factory Override Disables: C4

Factory Class: Base
  Parent:                   Not in Factory
  Sub-class Overrides:      C1, C2, C3, C4, C5
  Manual Overrides:         None
  Manual Override Disables: None
  Factory Override:         C5
Factory Class: C1
  Parent:                   Base
  Sub-class Overrides:      C3, C5
  Manual Overrides:         C3
  Manual Override Disables: None
  Factory Override:         C3
Factory Class: C2
  Parent:                   Base
  Sub-class Overrides:      C4
  Manual Overrides:         None
  Manual Override Disables: None
  Factory Override:         C2
Factory Class: C3
  Parent:                   C1
  Sub-class Overrides:      None
  Manual Overrides:         None
  Manual Override Disables: None
  Factory Override:         C3
Factory Class: C4
  Parent:                   C2
  Sub-class Overrides:      None
  Manual Overrides:         None
  Manual Override Disables: None
  Factory Override:         C4
Factory Class: C5
  Parent:                   C1
  Sub-class Overrides:      None
  Manual Overrides:         None
  Manual Override Disables: None
  Factory Override:         C5
Factory Class: Array
  Parent:                   Not in Factory
  Sub-class Overrides:      Array2
  Manual Overrides:         None
  Manual Override Disables: Array2
  Factory Override:         Array
Factory Class: Array2
  Parent:                   Array
  Sub-class Overrides:      None
  Manual Overrides:         None
  Manual Override Disables: None
  Factory Override:         Array2
		TXT

		assert_equal expected_string, Factory.print_overrides(true)

	end

end

