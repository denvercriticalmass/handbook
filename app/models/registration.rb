# The one gate every registration path goes through, password or OmniAuth.
#
# Deliberately not a validation on User: specs and seeds create users directly
# as preconditions, and a validation would reject them.
class Registration
  def initialize(email_address:, password:)
    @email_address = email_address.to_s.strip.downcase
    @password = password
  end

  def create
    User.create(email_address: email_address, password: password, role: :superadmin) if founding?
  end

  private

    attr_reader :email_address, :password

    def founding?
      User.count.zero? && email_address == superadmin_email
    end

    # Fails closed. With SUPERADMIN_EMAIL unset this is nil, which no submitted
    # address can equal, so nobody can claim the first account.
    def superadmin_email
      ENV["SUPERADMIN_EMAIL"].to_s.strip.downcase.presence
    end
end
