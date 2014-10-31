require 'camping'
require 'active_record'

Camping.goes :Battleship

module Battleship::Controllers
  class Index
    def get
      @shots_fired = Shot.fired
      render :shots_fired
    end
  end

  class Next
    def post
      Shot.fire!
      redirect Index
    end
  end

  class Reset
    def post
      Shot.reset!
      redirect Index
    end
  end

end

module Battleship::Views
  def layout
    html do
      head do
        title { 'Battleship!' }
      end
      body do
        h1 'iTransact Battleship!'
        form :action => '/next', :method => 'POST' do
          input :type => 'submit', :value => 'Fire!'
        end
        form :action => '/reset', :method => 'POST' do
          input :type => 'submit', :value => 'Reset!'
        end
        h2 'Shots fired so far:'
        self << yield
      end
    end
  end

  def shots_fired
    @shots_fired.order('updated_at DESC').each do |shot|
      p [shot.col, shot.row].join
    end
  end
end

module Battleship::Models
  class Shot < Base
    class << self
      def reset!
        delete_all
        %w(A B C D E F G H I J).each do |col|
          %w(1 2 3 4 5 6 7 8 9 10).each do |row|
            create!(col: col, row: row, fired: false)
          end
        end
        all
      end

      def fired
        where(fired: true)
      end

      def unfired
        where(fired: false)
      end

      def fire!
        unfired_shot = unfired_random
        create!(:col => unfired_shot.col, :row => unfired_shot.row, :fired => true)
      end

      def unfired_random
        unfired_shots = unfired
        unfired_shots[rand(unfired_shots.count)]
      end
    end
  end

  class ShotFields < V 1.0
    def self.up
      create_table Shot.table_name do |t|
        t.string :col
        t.string :row
        t.boolean :fired
        t.timestamps
      end
    end
    def self.down
      drop_table Shot.table_name
    end
  end
end

Battleship::Models::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/battleship')

def Battleship.create
  Battleship::Models.create_schema
end
