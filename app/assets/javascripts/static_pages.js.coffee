# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(".select2").select2
    width: "resolve"
    placeholder: "Select an option"
    allowClear: true
    ajax:
      url: "/options"
      dataType: "json"
      quietMillis: 100,
      data: (term, page) ->
        q: term
      results: (data, page) ->
        results: data
      cache: true
    formatResult: (item) -> item.label
    formatSelection: (item) -> item.label
    dropdownCssClass: "bigdrop"
