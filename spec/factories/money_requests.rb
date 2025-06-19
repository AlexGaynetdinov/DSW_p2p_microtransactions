FactoryBot.define do
  factory :money_request do
    requester { nil }
    recipient { nil }
    amount { "9.99" }
    message { "MyString" }
    status { "MyString" }
  end
end
