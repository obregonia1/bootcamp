# frozen_string_literal: true

require 'net/http'
require 'nokogiri'

class GithubGrass
  TABLE_SELECTOR = 'table.ContributionCalendar-grid.js-calendar-graph-table'
  LABEL_SELECTOR = 'td.ContributionCalendar-label span[aria-hidden="true"]'
  SELECTORS_TO_REMOVE = ['tool-tip', 'caption', 'span[class="sr-only"]'].freeze

  WDAYS = {
    Sun: '日', Mon: '月', Tue: '火', Wed: '水',
    Thu: '木', Fri: '金', Sat: '土'
  }.freeze

  MONTHS = {
    Jan: '1', Feb: '2', Mar: '3', Apr: '4',
    May: '5', Jun: '6', Jul: '7', Aug: '8',
    Sep: '9', Oct: '10', Nov: '11', Dec: '12'
  }.freeze

  def initialize(name)
    @name = name
  end

  def fetch
    table = extract_table(fetch_page)
    localize_date_label(table).to_s
  rescue StandardError
    ''
  end

  private

  def extract_table(html)
    table = Nokogiri::HTML(html, nil, 'UTF-8').css(TABLE_SELECTOR)
    SELECTORS_TO_REMOVE.each { |selector| table.search(selector).remove }
    table
  end

  def fetch_page
    uri = URI.parse(github_contributions_url(@name))
    response = Net::HTTP.get_response(uri)
    response.body
  end

  def localize_date_label(table)
    table.css(LABEL_SELECTOR).each do |label|
      english_abbreviation = label.children.text.strip
      replace_month_with_number(label, english_abbreviation)
      replace_wday_with_japanese(label, english_abbreviation)
    end
    table
  end

  def replace_month_with_number(label, abbreviation)
    return unless MONTHS.key?(abbreviation.to_sym)

    label.children = MONTHS[abbreviation.to_sym]
    label[:class] = 'months'
  end

  def replace_wday_with_japanese(label, abbreviation)
    return unless WDAYS.key?(abbreviation.to_sym)

    label.children = WDAYS[abbreviation.to_sym]
    label[:class] = 'wdays'
  end

  def github_contributions_url(name)
    "https://github.com/users/#{name}/contributions"
  end
end
