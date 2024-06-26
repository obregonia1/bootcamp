# frozen_string_literal: true

require 'test_helper'

class RegularEventTest < ActiveSupport::TestCase
  test '#organizers' do
    regular_event = regular_events(:regular_event1)
    organizers = users(:komagata)
    assert_includes regular_event.organizers, organizers
  end

  test 'is invalid when start_at >= end_at' do
    regular_event = regular_events(:regular_event1)
    regular_event.end_at = regular_event.start_at - 1.hour
    assert regular_event.invalid?
  end

  test '#holding_today?' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2022, 6, 5, 0, 0, 0) do
      assert regular_event.holding_today?
    end

    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_not regular_event.holding_today?
    end
  end

  test '#convert_date_into_week' do
    regular_event = regular_events(:regular_event1)
    assert_equal 1, regular_event.convert_date_into_week(1)
    assert_equal 2, regular_event.convert_date_into_week(8)
    assert_equal 3, regular_event.convert_date_into_week(15)
    assert_equal 4, regular_event.convert_date_into_week(22)
  end

  test '#next_event_date' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), regular_event.next_event_date
    end
  end

  test '#possible_next_event_date' do
    regular_event = regular_events(:regular_event1)
    regular_event_repeat_rule = regular_event_repeat_rules(:regular_event_repeat_rule1)
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      first_day = Time.zone.today
      assert_equal Date.new(2022, 6, 5), regular_event.possible_next_event_date(first_day, regular_event_repeat_rule)
    end

    holiday_not_held_event = regular_events(:regular_event1)
    repeat_rule = regular_event_repeat_rules(:regular_event_repeat_rule36) # 第1週水曜日
    travel_to Time.zone.local(2020, 1, 1, 0, 0, 0) do
      first_day = Time.zone.today
      assert_equal Date.new(2020, 2, 5), holiday_not_held_event.possible_next_event_date(first_day, repeat_rule)
    end
  end

  test '#next_specific_day_of_the_week' do
    regular_event = regular_events(:regular_event1)
    regular_event_repeat_rule = regular_event_repeat_rules(:regular_event_repeat_rule1)
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), regular_event.next_specific_day_of_the_week(regular_event_repeat_rule)
    end

    holiday_not_held_event = regular_events(:regular_event1)
    repeat_rule = regular_event_repeat_rules(:regular_event_repeat_rule35) # 毎週水曜日
    travel_to Time.zone.local(2020, 1, 1, 0, 0, 0) do
      first_day = Time.zone.today
      assert_equal Date.new(2020, 1, 8), holiday_not_held_event.possible_next_event_date(first_day, repeat_rule)
    end
  end

  test '#calculate_date_of_specific_nth_day_of_the_week' do
    regular_event = regular_events(:regular_event1)
    repeat_rule = regular_event_repeat_rules(:regular_event_repeat_rule2)
    days_of_the_week_count = 7

    travel_to Time.zone.local(2020, 1, 1, 0, 0, 0) do
      first_day = Time.zone.today
      assert_equal Date.new(2020, 1, 6), regular_event.calculate_date_of_specific_nth_day_of_the_week(repeat_rule, first_day, days_of_the_week_count)
    end
  end

  test '#holding_tomorrow?' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2023, 2, 25, 0, 0, 0) do
      assert regular_event.holding_tomorrow?
    end

    travel_to Time.zone.local(2023, 2, 26, 0, 0, 0) do
      assert_not regular_event.holding_tomorrow?
    end
  end

  test '#holding_day_after_tomorrow?' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2022, 12, 30, 0, 0, 0) do
      assert regular_event.holding_day_after_tomorrow?
    end

    travel_to Time.zone.local(2022, 1, 1, 0, 0, 0) do
      assert_not regular_event.holding_day_after_tomorrow?
    end
  end

  test '#cancel_participation' do
    regular_event = regular_events(:regular_event1)
    participant = regular_event_participations(:regular_event_participation1).user

    regular_event.cancel_participation(participant)
    assert_not regular_event.regular_event_participations.find_by(user_id: participant.id)
  end

  test '#watched_by?' do
    regular_event = regular_events(:regular_event1)
    user = users(:kimura)
    assert_not regular_event.watched_by?(user)

    watch = Watch.new(user:, watchable: regular_event)
    watch.save
    assert regular_event.watched_by?(user)
  end

  test '#participated_by?' do
    regular_event = regular_events(:regular_event1)
    user = users(:hatsuno)
    assert regular_event.participated_by?(user)

    user = users(:komagata)
    assert_not regular_event.participated_by?(user)
  end

  test '#assign_admin_as_organizer_if_none' do
    regular_event = RegularEvent.new(
      title: '主催者のいないイベント',
      description: '主催者のいないイベント',
      finished: false,
      hold_national_holiday: false,
      start_at: Time.zone.local(2020, 1, 1, 21, 0, 0),
      end_at: Time.zone.local(2020, 1, 1, 22, 0, 0),
      user: users(:kimura),
      category: 0,
      published_at: '2023-08-01 00:00:00'
    )
    regular_event.save(validate: false)
    regular_event.assign_admin_as_organizer_if_none
    assert_equal User.find_by(login_name: User::DEFAULT_REGULAR_EVENT_ORGANIZER), regular_event.organizers.first
  end
end
