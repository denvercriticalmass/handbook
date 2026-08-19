# Both registration paths call this, password and OmniAuth.
#
# Not a validation on User: specs and seeds create users directly, and a
# validation would reject them.
class Registration
  def initialize(email_address:, password:, name:, token: nil)
    @email_address = email_address.to_s.strip.downcase
    @password = password
    @name = name
    @token = token
  end

  def create
    user = founding? ? found_the_first_account : accept_invitation
    user if user&.persisted?
  end

  private

    attr_reader :email_address, :password, :name, :token

    def founding?
      User.count.zero? && email_address == superadmin_email
    end

    # Unset means nil, which no submitted address equals, so registration stays
    # closed.
    def superadmin_email
      ENV["SUPERADMIN_EMAIL"].to_s.strip.downcase.presence
    end

    def found_the_first_account
      User.create(email_address:, password:, name:, role: :superadmin)
    end

    def accept_invitation
      invitation = usable_invitation
      return if invitation.nil?

      User.transaction do
        User.create(email_address:, password:, name:).tap do
          invitation.update!(accepted_at: Time.current) if it.persisted?
        end
      end
    end

    # Matches on both keys. The blank guard matters if token is ever made
    # nullable, since find_by would then match a row.
    def usable_invitation
      return if token.blank?

      Invitation.usable.find_by(email_address:, token:)
    end
end
