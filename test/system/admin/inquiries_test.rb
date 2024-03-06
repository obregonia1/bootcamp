# frozen_string_literal: true

require 'application_system_test_case'

class Admin::InquiriesTest < ApplicationSystemTestCase
  test 'show listing inquiries' do
    visit_with_auth '/admin/inquiries', 'komagata'
    assert_equal '管理ページ | FBC', title
    assert_selector 'h1.page-main-header__title', text: 'お問い合わせ一覧'
    assert_text inquiries(:inquiry1).name
    assert_text inquiries(:inquiry2).name
  end

  test 'show inquiry details' do
    visit_with_auth '/admin/inquiries', 'komagata'
    all('.card-list-item__inner')[0].click

    assert_text inquiries(:inquiry1).name
    assert_text inquiries(:inquiry1).email
    assert_text I18n.l inquiries(:inquiry1).created_at.to_date
    assert_text inquiries(:inquiry1).body
  end

  test 'click on the link of back to inquiries index' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    click_link 'お問い合わせ一覧へ'

    assert_selector 'h1.page-main-header__title', text: 'お問い合わせ一覧'
  end
end