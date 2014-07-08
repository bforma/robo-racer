FactoryGirl.define do
  factory :checkpoint, class: Projections::Mongo::Checkpoint do
    x 1
    y 1
    priority 1
  end
end
