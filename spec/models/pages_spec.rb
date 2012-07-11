require 'spec_helper'



shared_examples_for "ActiveModel" do
  include ActiveModel::Lint::Tests

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
    example m.gsub('_',' ') do
      send m
    end
  end

  def model
    subject
  end
end

describe Pages do
  it_should_behave_like "ActiveModel"



end
#describe Pages do
#  pending "add some examples to (or delete) #{__FILE__}"
#end
