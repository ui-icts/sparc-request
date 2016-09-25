require "rails_helper"

RSpec.describe UserMailer do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  context "added an authorized user" do
    before :each do
      @modified_identity        = create(:identity)
      @identity                 = create(:identity)
      @protocol_role            = create(:project_role, protocol: study, identity: @modified_identity, project_rights: 'approve', role: 'consultant')
      @mail = UserMailer.authorized_user_changed(@identity, study, @modified_identity, 'add')
    end
  
    it "should display the 'added' message" do
      # An Authorized User has been added in SparcDashboard ***(link to protocol)***
      expect(@mail).to have_xpath("//p[normalize-space(text()) = 'An Authorized User has been added in']")
      expect(@mail).to have_xpath "//p//a[@href='/dashboard/protocols/#{study.id}'][text()= 'SPARCDashboard.']/@href"
    end

    it "should display the Protocol information table" do
      protocol_information_table
    end

    it "should display the User information table" do
      user_information_table
    end

    it "should display message conclusion" do
      expect(@mail).to have_xpath("//p[normalize-space(text()) = 'Please contact the SUCCESS Center at (843) 792-8300 or success@musc.edu for assistance with this process or with any questions you may have.']")
    end

    it "should display acknowledgments" do
      study.service_requests.first.service_list.map{|k, v| v[:acks]}.flatten.uniq.each do |ack|
        expect(@mail).to have_xpath("//p[normalize-space(text()) = '#{ack}']")
      end
    end
  end

  context "deleted an authorized user" do
    before :each do
      @modified_identity        = create(:identity)
      @identity                 = create(:identity)
      @protocol_role            = create(:project_role, protocol: study, identity: @modified_identity, project_rights: 'approve', role: 'consultant')
      @mail = UserMailer.authorized_user_changed(@identity, study, @modified_identity, 'destroy')
    end

    it "should display the 'deleted' message" do
      # An Authorized User has been deleted in SparcDashboard ***(link to protocol)***
      expect(@mail).to have_xpath("//p[normalize-space(text()) = 'An Authorized User has been deleted in']")
      expect(@mail).to have_xpath "//p//a[@href='/dashboard/protocols/#{study.id}'][text()= 'SPARCDashboard.']/@href"
    end

    it "should display the Protocol information table" do
      protocol_information_table
    end

    it "should display the User information table" do
      user_information_table
    end

    it "should display message conclusion" do
      expect(@mail).to have_xpath("//p[normalize-space(text()) = 'Please contact the SUCCESS Center at (843) 792-8300 or success@musc.edu for assistance with this process or with any questions you may have.']")
    end

    it "should display acknowledgments" do
      study.service_requests.first.service_list.map{|k, v| v[:acks]}.flatten.uniq.each do |ack|
        expect(@mail).to have_xpath("//p[normalize-space(text()) = '#{ack}']")
      end
    end
  end
end