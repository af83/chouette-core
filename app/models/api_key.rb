class ApiKey < ApplicationModel
  has_metadata

  before_validation :generate_access_token, on: :create

  belongs_to :workbench

  validates :workbench, presence: true
  validates :token, presence: true, uniqueness: true

  def eql?(other)
    return false unless other.respond_to?(:token)
    other.token == token
  end

  private

  def generate_access_token
    return if token.present?

    loop do
      self.token = SecureRandom.hex
      break token if self.class.where(token: token).blank?
    end
  end
end
