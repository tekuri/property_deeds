class Task < ActiveRecord::Base
  attr_accessor :done, :due, :name, :notes, :priority
end