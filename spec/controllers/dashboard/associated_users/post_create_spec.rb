require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'POST create' do
    def errors_stub(message)
      double(ActiveModel::Errors, full_messages: [message])
    end

    let!(:identity) { build_stubbed(:identity) }

    let!(:protocol) { findable_stub(Protocol) { build_stubbed(:protocol) } }

    context "User not authorized to edit Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: false)
        log_in_dashboard_identity(obj: identity)

        xhr :post, :create, protocol_id: protocol.id, format: :js
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(protocol, identity)
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol and params[:project_role] describes valid ProjectRole" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        @new_project_roles_attrs = "@new_project_roles_attrs"
        associated_user_creator = instance_double(Dashboard::AssociatedUserCreator,
          successful?: true)
        allow(Dashboard::AssociatedUserCreator).to receive(:new).
          and_return(associated_user_creator)

        xhr :post, :create, protocol_id: protocol.id, project_role: @new_project_roles_attrs, format: :js
      end

      it "should use Dashboard::AssociatedUserCreator to create ProjectRole" do
        expect(Dashboard::AssociatedUserCreator).to have_received(:new).
          with(@new_project_roles_attrs)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/associated_users/create" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol and params[:project_role] describes an invalid ProjectRole" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        @new_project_roles_attrs = "@new_project_roles_attrs"
        new_project_role = build_stubbed(:project_role)
        allow(new_project_role).to receive(:errors).and_return("my errors")
        associated_user_creator = instance_double(Dashboard::AssociatedUserCreator,
          successful?: false,
          protocol_role: new_project_role)

        allow(Dashboard::AssociatedUserCreator).to receive(:new).
          and_return(associated_user_creator)

        xhr :post, :create, protocol_id: protocol.id, project_role: @new_project_roles_attrs, format: :js
      end

      it "should use Dashboard::AssociatedUserCreator to (attempt) to create ProjectRole" do
        expect(Dashboard::AssociatedUserCreator).to have_received(:new).
          with(@new_project_roles_attrs)
      end

      it "should set @errors from built ProjectRole's errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/associated_users/create" }
      it { is_expected.to respond_with :ok }
    end
  end
end
