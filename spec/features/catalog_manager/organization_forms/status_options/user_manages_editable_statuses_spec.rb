# Copyright © 2011-2018 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe 'User manages status options', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution        = create(:institution)
    @provider           = create(:provider, parent_id: @institution.id, process_ssrs: true, use_default_statuses: false)
    @catalog_manager    = create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
  end

  context 'and Use Default Statuses option is false' do
    context 'with available status selected' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id}").click
        wait_for_javascript_to_finish
        click_link @provider.name
        wait_for_javascript_to_finish

        click_link 'Status Options'
        wait_for_javascript_to_finish
        within :css, "#status-row-ctrc_approved" do
          unless page.has_field?(class: 'available-status-checkbox', checked: true, count: 1)
            check class: 'available-status-checkbox'
            wait_until { page.document.has_content?("Status updated successfully.") }
          end

          unless page.has_field?(class: 'editable-status-checkbox', checked: false, count: 1)
            uncheck class: 'editable-status-checkbox'
            wait_until { page.document.has_content?("Status updated successfully.") }
          end
        end
      end

      it 'should add the editable status' do
        within :css, "#status-row-ctrc_approved" do
          check class: 'editable-status-checkbox'
        end
        wait_until { page.has_content?("Status updated successfully.") }

        within :css, '#status-row-ctrc_approved' do
          expect(page).to have_field(class: 'editable-status-checkbox', disabled: false, count: 1)
        end
        expect(EditableStatus.where(organization_id: @provider.id).first.selected).to eq(true)
      end

      it 'should remove the editable status' do
        within :css, '#status-row-ctrc_approved' do
          expect(page).to have_field(class: 'editable-status-checkbox', disabled: false, count: 1)
        end
        expect(EditableStatus.where(organization_id: @provider.id).first.selected).to eq(false)
      end

    end

    context 'with available status not selected' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id}").click
        wait_for_javascript_to_finish
        click_link @provider.name
        wait_for_javascript_to_finish

        click_link 'Status Options'
        wait_for_javascript_to_finish
      end

      it 'should not select the editable status' do
        within :css, "#status-row-ctrc_approved" do
          expect(page).to have_field(class: 'editable-status-checkbox', disabled: true, count: 1)
        end

        expect(EditableStatus.where(organization_id: @provider.id).first.selected).to eq(false)
      end
    end

    context 'with disabled available status' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id}").click
        wait_for_javascript_to_finish
        click_link @provider.name
        wait_for_javascript_to_finish

        click_link 'Status Options'
        wait_for_javascript_to_finish
      end

      it 'should not select the disabled editable status' do
        within :css, "#status-row-ctrc_approved" do
          expect(page).to have_field(class: 'editable-status-checkbox', disabled: true, count: 1)
        end

      end
    end

    context 'with user is not overlord' do
      before :each do
        @catalog_manager.identity.update_attributes(catalog_overlord: false)
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id}").click
        wait_for_javascript_to_finish
        click_link @provider.name
        wait_for_javascript_to_finish

        click_link 'Status Options'
        wait_for_javascript_to_finish
        within :css, '#status-row-ctrc_approved' do
          check class: 'available-status-checkbox', count: 1
          wait_until { page.document.has_content?("Status updated successfully.") }
        end

      end

      it 'should not select the editable status' do
        within :css, '#status-row-ctrc_approved' do
          expect(page).to have_field(class: 'editable-status-checkbox', disabled: true, count: 1)
        end

      end
    end

  end

end
