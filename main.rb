# frozen_string_literal: true

# rubocop: disable Lint/SuppressedException
require 'rubygems'
require 'selenium-webdriver'
require_relative './credentials'

# Get Project From Microverse
class Microverse
  attr_reader :browser, :wait, :claim
  def initialize
    @browser = Selenium::WebDriver.for :firefox
    @browser.get 'https://dashboard.microverse.org/login'

    @wait = Selenium::WebDriver::Wait.new(timeout: 60)
    @claim = Selenium::WebDriver::Wait.new(timeout: 10)
  end

  def login!
    # Add Username
    fill_input('email', ENV['GMAIL_USERNAME'])

    # Add Password
    fill_input('password', ENV['GMAIL_PASSWORD'])

    # Submit
    click_input(:name, 'submit')
  end

  def find_project
    # Go to code review section / Refresh Page
    click_input(:link_text, 'Code Review Requests')

    link = claim.until do
      element = browser.find_element(:link_text, 'Claim')
      element if element.displayed?
    end
    link.click
    link
  rescue Selenium::WebDriver::Error::TimeoutError
  end

  def claim_project
    # Nav to Code Reviews
    link = find_project until link
    true
  rescue Selenium::WebDriver::Error::UnknownError
  end

  private

  def click_input(type, text)
    input = wait.until do
      element = browser.find_element(type, text)
      element if element.displayed?
    end
    input.click
  end

  def fill_input(name, value)
    input = wait.until do
      element = browser.find_element(:name, name)
      element if element.displayed?
    end
    input.send_keys(value)
  end
end
# rubocop: enable Lint/SuppressedException
microverse = Microverse.new
microverse.login!
link = microverse.claim_project until link
text = '<span font="24">You Got A Project!</span>'
span = "--text '#{text}'"
title = '--title="New Project!"'
system("zenity --info #{span} #{title} --width=300 --height=100")
