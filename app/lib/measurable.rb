# Provides shortcuts to use Chouette::Benchmark measure method in a Ruby class.
#
# To measure a given block:
#
#   def foo
#      measure "foo", target: target.id do
#        # ...
#      end
#   end
#
# To measure a existing method:
#
#   def foo
#     # ...
#   end
#   measure :foo

module Measurable
  extend ActiveSupport::Concern

  # Measure the given block with the given options
  def measure(*args, &block)
    Chouette::Benchmark.measure(*args, &block)
  end

  class_methods do

    # Use #measure when the given methods are invoked
    def measure(*method_names)
      proxy = Module.new do
        method_names.each do |measured_method|
          define_method measured_method do |*args, &block|
            measure measured_method do
              super(*args, &block)
            end
          end
        end
      end

      prepend proxy
    end

  end

end
