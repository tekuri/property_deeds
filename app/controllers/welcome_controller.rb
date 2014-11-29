class WelcomeController < ApplicationController
  layout :resolve_layout

  #layout "application"

  #before_filter :authenticate_user!, :except => [:login, :reset_password]

  def index
    User.current = current_user
    render :inline => "<%= netzke :main_application %>", :layout => true
  end

  def login
    render :inline => "<%= netzke :login %>", :layout => true
  end

  def reset_password
    render :inline => "<%=netzke :reset_password %>", :layout => true
  end

  def order_time_line
    order = Order.find(params[:id].to_i)
    timelines = order.time_lines
    source = []
    timelines.each{|time_line|
      values = []
      fields = {}
      start_date = time_line.start_date
      end_date = time_line.end_date
      if start_date.present? and end_date.present?
        fields["from"] = "/Date(#{start_date.to_time_in_current_zone.to_i*1000})/"
        fields["to"] = "/Date(#{end_date.to_time_in_current_zone.to_i*1000})/"
        fields["customClass"] = get_color(time_line)
        values << fields
        source << {"name" => TimeLine::TIME_LINE_JOBS["#{time_line.job}"], "values" => values}
      end
    }
    if source.blank?
      render :text => "<h1>Timeline not created.</h1>"
    else
      render 'time_line',  :locals => {:source => source.to_json}
    end
  end

  private

  def resolve_layout
    case action_name
      when "order_time_line"
        "timeline"
      else
        "application"
    end
  end

  def get_color(time_line)
    if Date.today >= time_line.start_date and Date.today <= time_line.end_date
      return "ganttYellow"
    elsif time_line.end_date < Date.today
      return "ganttGreen"
    else
      return "ganttRed"
    end
  end

end
