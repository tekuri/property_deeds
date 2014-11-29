class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.current=(user_obj)
    Thread.current[:user] = user_obj
    Company.current = user_obj.default_company if user_obj
  end

  def self.current
    Thread.current[:user]
  end
end
