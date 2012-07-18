# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :google do
    query "MyText"
    query_rank "MyText"
    query_number 1
    title "MyText"
    description "MyText"
    url "MyText"
  end
end
