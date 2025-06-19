FactoryBot.define do
  factory :transaction do
    sender { nil }
    recipient { nil }
    amount { "9.99" }
    message { "MyString" }
  end
end
