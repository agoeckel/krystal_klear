class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :registerable and :omniauthable
  has_many :routes, foreign_key: :employee_id
  has_many :employee_work_orders
  has_many :work_orders, through: :employee_work_orders
  has_many :current_week_routes, ->{where("work_orders.week = ?", Time.now.strftime('%W').to_i)}, through: :work_orders, source: :route
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :email, :phone, :encrypted_password, {presence: true}
  validates :email, uniqueness: true

  def sum_routes
    total = 0
    self.routes.each { |route| total += route.sum_jobs }
    return total
  end

end
