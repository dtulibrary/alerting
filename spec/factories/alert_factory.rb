FactoryGirl.define do
  factory :alert1, class: Alert do
    name "my favorite alert"
    query "chocolate"
    frequency 1 
    alert_type "search" 
    user_id "1234"
  end

  factory :alert2, class: Alert do
    name "my new favorite alert"
    query "chocolate AND cake"
    frequency 2
    alert_type "search" 
    user_id "1234"
  end

  factory :alert3, class: Alert do
    query "16838602"
    frequency 3 
    alert_type "journal" 
    user_id "4321"
  end
end