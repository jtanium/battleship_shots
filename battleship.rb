Camping.goes :Battleship

module Battleship::Controllers
  class Index < R '/'
    def get
      @time = Time.now.to_s
      render :sundial
    end
  end
end

module Battleship::Views
  def layout
    html do
      head do
        title { 'Battleship!' }
      end
      body { self << yield }
    end
  end

  def sundial
    p "The current time is: #{@time}"
  end
end

