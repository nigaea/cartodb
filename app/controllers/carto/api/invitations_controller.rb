# encoding: UTF-8

module Carto
  module Api
    class InvitationsController < ::Api::ApplicationController

      ssl_required :create

      before_filter :load_organization

      def create
        invitation = Carto::Invitation.create_new(
          params[:users_emails],
          params[:welcome_text]
        )
        if invitation.valid?
          render_jsonp(Carto::Api::InvitationPresenter.new(invitation).to_poro)
        else
          render json: { errors: invitation.errors }, status: 400
        end
      rescue => e
        CartoDB.notify_exception(e, { params: params , invitation: (invitation ? invitation : 'not created') })
        render json: { errors: e.message }, status: 500
      end

      private

      def load_organization
        @organization = Carto::Organization.where(id: params[:organization_id]).first
        render_404 and return unless @organization
        unless @organization.owner.id == current_user.id
          render_jsonp({ errors: { organization: 'not owner' } }, 401) and return
        end
      end

    end
  end
end
