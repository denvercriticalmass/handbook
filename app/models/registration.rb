# The one gate every registration path goes through, password or OmniAuth.
#
# Deliberately not a validation on User: specs and seeds create users directly
# as preconditions, and a validation would reject them.
class Registration
  def initialize(email_address:, password:, token: nil)
    @email_address = email_address.to_s.strip.downcase
    @password = password
    @token = token
  end

  def create
    user = founding? ? found_the_first_account : accept_invitation
    user if user&.persisted?
  end

  private

    attr_reader :email_address, :password, :token

    def founding?
      User.count.zero? && email_address == superadmin_email
    end

    # Fails closed. With SUPERADMIN_EMAIL unset this is nil, which no submitted
    # address can equal, so nobody can claim the first account.
    def superadmin_email
      ENV["SUPERADMIN_EMAIL"].to_s.strip.downcase.presence
    end

    def found_the_first_account
      User.create(email_address:, password:, role: :superadmin)
    end

    def accept_invitation
      invitation = usable_invitation
      return if invitation.nil?

      User.transaction do
        User.create(email_address:, password:).tap do
          invitation.update!(accepted_at: Time.current) if it.persisted?
        end
      end
    end

    # Both keys, so knowing an invited address isn't enough on its own. The
    # blank guard matters if the token column is ever made nullable, since
    # find_by would then match a row instead of nothing.
    def usable_invitation
      return if token.blank?

      Invitation.usable.find_by(email_address:, token:)
    end
end
