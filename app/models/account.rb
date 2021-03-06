class Account < ActiveRecord::Base
  has_many :expenses
  has_many :bills

  serialize :meta, Hash

  validates :name, presence: true

  def icon
    attributes['icon'] || 'usd'
  end

  def icon_class
    "icon-#{self.icon}"
  end
end
