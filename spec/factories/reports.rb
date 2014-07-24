# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report do
    github_key "MyString"
    basic_distribution ""
    github_stars ""
  end
end
