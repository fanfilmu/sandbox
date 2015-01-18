def have_select2(locator, options={})
  Capybara::HaveSelect2.new(locator, options)
end

def select2(value, options={})
  select2 = Capybara::Select2.new(page, options[:from])
  select2.select(value)
end

module Capybara
  module Js
    def async(page)
      page.execute_script("ajax_notification = { started: false, completed: false }")
      page.execute_script("$(document).ajaxStart(function() { ajax_notification.started = true; })")
      page.execute_script("$(document).ajaxStop(function() { ajax_notification.completed = true; })")

      yield

      sleep(0.3) # wait for handlers to fire
      if page.evaluate_script("ajax_notification.started")
        until page.evaluate_script("ajax_notification.completed")
          sleep(0.1)
        end
      end
    end
  end

  class HaveSelect2
    def initialize(locator, options={})
      @locator = locator
      @options = options[:options]
      @with_options = options[:with_options]
      @selected = options[:selected]
      @failure_reason = :not_select2
    end

    def matches?(page)
      @select2 = Capybara::Select2.new(page, @locator)

      (@select2.is_select2? or fail(:not_select2)) and
      (@options.nil?        or @select2.options.sort == @options.sort      or fail(:invalid_options)) and
      (@with_options.nil?   or (@with_options - @select2.options).empty?   or fail(:invalid_options)) and
      (@selected.nil?       or @select2.selected == @selected              or fail(:invalid_selected))
    end

    def failure_message
      failure_messages[@failure_reason]
    end

    def failure_message_when_negated
      message = "Expected #{@locator} not to be associated with select2, but it is"
      message << ", has exactly these options: #{@options}" if @options
      message << ", has all of these options: #{@with_options}" if @with_options
      message << ", with selected option #{@selected}" if @selected
      message
    end

    def description
      "#{@locator} should be associated with select2"
    end

    private
    def fail(reason)
      @failure_reason = reason
      false
    end

    def failure_messages
      {
        not_found: "couldn't locate object #{@locator}",
        not_select2: "expected #{@element[:id]} is not associated with select2",
        invalid_options: "couldn't match #{@options or @with_options} to actual options: #{@select2.options}",
        invalid_selected: "expected #{@selected} to be chosen value, but it's #{@select2.selected}"
      }
    end
  end

  class Select2
    include Capybara::Js

    def initialize(page, locator)
      @page = page
      @locator = locator
      locate
    end

    def is_select2?
      @container.present?
    end

    def options
      click
      @page.all(".select2-result.select2-result-selectable").map(&:text)
    end

    def selected
      @container.find(".select2-chosen").text
    end

    def select(value)
      click
      @page.find("li.select2-result.select2-result-selectable", text: value).click
    end

    def click
      @page.find(".select2-drop-mask").click if @page.has_css?(".select2-drop-mask")
      async(@page) { @container.click }
    end

    private
    def locate
      (find_by_label || find_by_name || find_by_css) && find_container
    end

    def find_by_label
      @label = @page.first("label[for]", text: @locator)
      @element = @page.find_by_id("#{@label[:for]}") if @label.present?
    end

    def find_by_name
      @element = @page.first(:css, "*[name='#{@locator}']", visible: false)
    end
    
    def find_by_css
      @element = @page.first(:css, @locator, visible: false)
    end

    def find_container
      if @label
        @container = @page.find(:xpath, "//*[@id='#{@element[:id]}']/..")
        @container = nil unless @container[:class].try(:include?, "select2-container")
      else
        @container = @page.first(:css, ".select2-container#s2id_#{@element[:id]}")
      end
    end
  end
end
