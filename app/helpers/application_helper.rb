module ApplicationHelper
  def designer
    @designer ||= Designer.new
  end
end
