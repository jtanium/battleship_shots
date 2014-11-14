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

  class Migrate
    def get
      Battleship::Models.create_schema
      redirect Index
    end
  end
end

module Battleship::Views
  def layout
    html do
      head do
        title { 'Battleship!' }
        link :rel => 'stylesheet', :href => 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css'
        link :rel => 'stylesheet', :href => 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css'
      end
      body do
        h1 'iTransact Battleship!'
        div :class => 'container' do
          p do
            form :action => '/next', :method => 'POST' do
              input :type => 'submit', :value => 'Fire! >>', :class => 'btn btn-primary btn-lg'
            end
          end
          h2 'Shots fired so far:'
          self << yield
          script :src => 'https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'
          script :src => 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js'
        end
      end
      form :action => '/reset', :method => 'POST' do
        input :type => 'submit', :value => 'Reset!', :class => 'btn btn-sm btn-danger'
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
        unfired_random.fire!
      end

      def unfired_random
        unfired_shots = unfired
        unfired_shots[rand(unfired_shots.count)]
      end
    end

    def fire!
      self.update_attribute(:fired, true)
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

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/battleship_development')
ActiveRecord::Base.establish_connection(
    :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8',
    :pool => ENV['MAX_THREADS'] || 20
)
