FactoryBot.define do
  factory :friendship do
    requester { nil }
    receiver { nil }
    status { "MyString" }
  end
end
