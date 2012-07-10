# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :result do
    session_id "MyText"
    db_name "MyText"
    query "MyText"
    query_rank 1
    title "MyText"
    description "MyText"
    url "MyText"
  end
end
