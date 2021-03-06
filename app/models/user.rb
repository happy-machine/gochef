class User < ApplicationRecord
  
  has_attached_file :avatar, styles: { medium: "300x300#", thumb: "100x100#", :square => "100x100#"  }, default_url: "no-image.jpg"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  acts_as_mappable :default_units => :miles,
  :default_formula => :sphere,
  :distance_field_name => :distance,
  :lat_column_name => :location_lat,
  :lng_column_name => :location_lon
  
  validates :name, presence: true
  validates :email, presence: true

  enum status: [:rating]
  has_many :reviews, -> { order(created_at: :desc) }
  has_many :ratings
  has_many :images

  after_initialize :init

  def init
    self.location_lat  ||= -0.09039        
    self.location_lon ||= 51.51264     
    self.range_to ||= 40 
    self.rating ||= 1
    self.average_rating ||= av_rating
  end
  #carrierwave upload mounting
  #mount_uploader :avatar, AvatarUploader
 
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def av_rating
    if reviews.count > 0 && ((reviews.map(&:rating).compact.sum.to_f)/(reviews.map(&:rating).compact.count)).round >= 1
        return ((reviews.map(&:rating).compact.sum.to_f)/(reviews.map(&:rating).compact.count)).round
    else 1
    end
  end

  def self.search(term)
    if term
      where('name ILIKE ?', "%#{term}%")
    else
      all
    end
  end

  
end
