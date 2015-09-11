require 'rails_helper'

RSpec.describe AdditionalDetail::AdditionalDetailsController do

  before :each do
    @institution = Institution.new
    @institution.type = "Institution"
    @institution.abbreviation = "TECHU"
    @institution.save(validate: false)

    @provider = Provider.new
    @provider.type = "Provider"
    @provider.abbreviation = "ICTS"
    @provider.parent_id = @institution.id
    @provider.save(validate: false)

    @program = Program.new
    @program.type = "Program"
    @program.name = "BMI"
    @program.parent_id = @provider.id
    @program.save(validate: false)

    @core = Core.new
    @core.type = "Core"
    @core.name = "REDCap"
    @core.parent_id = @program.id
    @core.save(validate: false)

    @core_service = Service.new
    @core_service.organization_id = @core.id
    @core_service.save(validate: false)

    @program_service = Service.new
    @program_service.organization_id = @program.id
    @program_service.save(validate: false)
    
    @additional_detail = AdditionalDetail.new
    @additional_detail.service_id = @core_service.id
    
  end

  describe 'user is not logged in and, thus, has no access to' do
    it 'a core service index' do
      get(:index, {:service_id => @core_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end

    it 'a program service index' do
      get(:index, {:service_id => @program_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end

    it 'a core service new additional detail page' do
      get(:new, {:service_id => @core_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end

    it 'a program service new additional detail page' do
      get(:new, {:service_id => @program_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end
  end

  describe 'authenticated identity' do
    before :each do
      @identity = Identity.new
      @identity.approved = true
      @identity.save(validate: false)
      session[:identity_id] = @identity.id
      # Devise test helper method: sign_in
      sign_in @identity
    end

    describe 'is not a catalog_manager or super_user and, thus, has no access to' do

      it 'a core service index' do
        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        #expect(assigns(:service)).to be_blank
      end

      it 'a core service index even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)

        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
      end

      it 'a program service index' do
        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
      end

      it 'a program service index even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)

        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
      end

      it 'a new core service additional detail page' do
        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end

      it 'a new core service additional detail page even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)

        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end

      it 'a new program service additional detail page' do
        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end

      it 'a new program service additional detail page even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)

        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end
    end

    describe 'is a catalog_manager and has access to' do
      it 'a core service index' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @core.id
        @catalog_manager.save(validate: false)

        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
      end

      it 'a core service index because user is a catalog_manager for its program' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false)

        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
      end

      it 'a program service index' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false)

        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
      end

      it 'a core service new additional detail page' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @core.id
        @catalog_manager.save(validate: false)

        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end

      it 'a core service new additional detail page because user is a catalog_manager for its program' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false)

        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end

      it 'a program service new additional detail page' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false)

        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end

      # CRUD an additional detail as a catalog_manager
      describe 'a core service and can' do
        before :each do
          @catalog_manager = CatalogManager.new
          @catalog_manager.identity_id = @identity.id
          @catalog_manager.organization_id = @core.id
          @catalog_manager.save(validate: false)
        end

        it 'create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Time.now, :approved => "true"}
            })
            expect(assigns(:additional_detail).errors).to be_blank
            expect(response).to redirect_to(additional_detail_service_additional_details_path(@core_service))
            #expect(assigns(:service)).to_not be_blank
            #expect(assigns(:additional_detail)).to be_blank
          }.to change(AdditionalDetail, :count).by(1)
        end
        
        it 'see failed validation for :description being too long' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "0"*256, :form_definition_json => "{}", :effective_date => Time.now, :approved => "true"}
            })
            expect(assigns(:additional_detail).errors[:description].size).to eq(1)
            message = "is too long (maximum is 255 characters)"
            expect(assigns(:additional_detail).errors[:description][0]).to eq(message)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end

        it 'see failed validation for blank :name when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Time.now, :approved => "true"}
            })
            expect(assigns(:additional_detail).errors[:name].size).to eq(1)
            expect(assigns(:additional_detail).errors[:effective_date].size).to eq(0)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end

        it 'see failed validation for blank :effective_date when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => "", :approved => "true"}
            })
            expect(assigns(:additional_detail).errors[:effective_date].size).to eq(1)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end
        
      it 'see failed validation for blank :effective_date when trying to create an additional detail record' do
                expect {
                  post(:create, {:service_id => @core_service, :format => :html,
                    :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => "", :approved => "true"}
                  })
                  expect(assigns(:additional_detail).errors[:effective_date].size).to eq(1)
                  expect(response).to render_template("new")
                  expect(response.status).to eq(200)
                  expect(assigns(:service)).to_not be_blank
                  expect(assigns(:additional_detail)).to_not be_blank
                }.to change(AdditionalDetail, :count).by(0)
              end
        
        it 'see failed validation for :effective_date that is already taken when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Time.now, :approved => "true"}
            })
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 2", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Time.now, :approved => "true"}
            })
            expect(assigns(:additional_detail).errors[:effective_date].size).to eq(1)
            message = "Effective date cannot be the same as any other effective dates."
            expect(assigns(:additional_detail).errors[:effective_date][0]).to eq(message)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(1)
        end

        it 'see failed validation for blank :form_definition_json when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "", :effective_date => Time.now, :approved => "true"}
            })
            expect(assigns(:additional_detail).errors[:form_definition_json].size).to eq(1)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end
        it 'see failed validation for form with no questions :form_definition_json when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => '{"schema": {"type": "object","title": "Comment","properties": {},"required": []},"form": []}',
              :effective_date => Time.now, :approved => "true"}
            })
            expect(assigns(:additional_detail).errors[:form_definition_json].size).to eq(1)
            message = "Form must contain at least one question."
            expect(assigns(:additional_detail).errors[:form_definition_json][0]).to eq(message)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end

      end

    end
    
#    describe 'Put update' do
#      before :each do
#        @additional_detail.name = "Form # 1"
#        @additional_detail.description = "10 essential questions" 
#        @additional_detail.form_definition_json = "{}"
#        @additional_detail.effective_date = Time.now
#        @additional_detail.approved = "true"
#      end
#        context "vaild attributes" do 
#          it "locate requested @additional_detail" do
#            put :update, id: @additional_detail, additional_detail: Factory.attributes_for(:additional_detail)
#                  expect(assigns(:additional_detail)).to eq(@additional_detail)
#          end
#        end
#      
#    end

    describe 'is a super_user and has access to' do
      it 'a core service index' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)

        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
      end

      it 'a program service index' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)

        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
      end

      it 'a core service new additional detail page' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)

        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end

      it 'a program service new additional detail page' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)

        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end
    end
  end
end
