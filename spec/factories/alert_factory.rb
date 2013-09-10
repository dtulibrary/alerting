# -*- encoding : utf-8 -*-

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

  factory :alert_stats, class: AlertStat do
    count 0        
    alert

    trait :now do
      last_run DateTime.current
    end

    trait :old do
      last_run DateTime.current - 2.months
    end
  end

  factory :alert do
    frequency 7
    user_id "1234"

    factory :search_alert do
      query "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
        utf8: ✓
        search_field: all_fields
        q: cake OR death
        action: index
        controller: catalog
        locale: en"
      alert_type "search"

      factory :new_search_alert1 do
        name "new 1"
        created_at 9.days.ago        
      end

      factory :new_search_alert2 do
        name "new 2"                
      end

      factory :not_ready_search_alert do
        name "should not run"
        after(:create) do |alert, evaluator|
          alert.alert_stats << FactoryGirl.create(:alert_stats, :now, :alert => alert)
        end
      end

      factory :ready_search_alert do
        name "should run"
        after(:create) do |alert, evaluator|
          alert.alert_stats << FactoryGirl.create(:alert_stats, :old, :alert => alert)
        end
      end
    end

    factory :journal_alert do
      alert_type "journal"
      
      factory :journal_alert_issn1a do
        name "Nature"
        query "14764687"
        created_at 9.days.ago
      end

      factory :journal_alert_issn1b do
        name "Nature"
        query "14764687"
        created_at 2.days.ago
      end

      factory :journal_alert_issn2 do
        name "Natural Resources"
        query "21587086"
        created_at 8.days.ago
      end
    end
  end

  factory :alert_query, class: Alert do
    alert_type "search"
    frequency "7"
    user_id 1234

    factory :alert_no_query do
      query "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
        action: index
        controller: catalog
        locale: en
        f: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          format:
          - article"
    end

    factory :alert_plain_query do
      query "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
        utf8: ✓
        search_field: all_fields
        q: test
        action: index
        controller: catalog
        locale: en"
    end

    factory :alert_facet_query do
      query "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
        q: test
        search_field: all_fields
        utf8: ✓
        action: index
        controller: catalog
        locale: en
        f: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          format:
          - article"
    end

    factory :alert_range_query do
      query "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
        utf8: ✓
        q: test
        search_field: all_fields
        locale: en
        action: index
        controller: catalog
        f: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          format:
          - article
        range: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          pub_date_tsort: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
            begin: '2010'
            end: '2011'"
    end

    factory :alert_multi_facet_query do
      query "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
        q: test
        search_field: all_fields
        utf8: ✓
        action: index
        controller: catalog
        locale: en
        f: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          author_facet:
          - ! \"Lee\"
          format:
          - article
          journal_title_facet:
          - Polish Journal of Cardiology
        t: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          test: ✓
        range: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
          pub_date_tsort: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
            begin: '2010'
            end: '2011'"
    end

    factory :alert_search_field do
      query "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
        utf8: ✓
        locale: en
        search_field: author
        q: Dijkstra, Edsger W.
        action: index
        controller: catalog"
    end
  end
end