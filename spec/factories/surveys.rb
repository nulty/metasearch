# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    norm_eng 1
    meta_better 1
    agg_non 1
    clust_non 1
    interface 1
    result_pres 1
    speed 1
    make_default false
    add_info "MyText"
  end
end
