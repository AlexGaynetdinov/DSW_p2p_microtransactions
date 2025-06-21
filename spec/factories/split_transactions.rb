FactoryBot.define do
  factory :split_transaction do
    creator { nil }
    amount { "9.99" }
    message { "MyString" }
  end
end
