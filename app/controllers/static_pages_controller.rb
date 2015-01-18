class StaticPagesController < ApplicationController
  def home
  end

  def options
    options = [
      { id: "options", label: "So many options" },
      { id: "choosing", label: "Don't know what to choose" },
      { id: "async", label: "Such asynchronous" },
      { id: "waiting", label: "Aren't you tired of waiting?" },
      { id: "labels", label: "And labels, such nice labels" },
      { id: "funniness", label: "Funny one" },
    ].select { |data| data[:label].downcase.include? params[:q].downcase }.shuffle.to_json  

    render json: options
  end
end
