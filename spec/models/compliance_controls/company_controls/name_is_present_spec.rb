require 'rails_helper'

RSpec.describe CompanyControl::NameIsPresent, :type => :model do
  let!(:line_referential){ create :line_referential }
  let!(:referential){ create :referential, line_referential: line_referential }
  let!(:company){ create :company, line_referential: line_referential }
  let(:control_attributes){
    {}
  }
  let(:company_name){ "A NAME" }
  let(:criticity){ "error" }
  let(:compliance_check_set){ create :compliance_check_set, referential: referential}
  let(:compliance_check){
    create :compliance_check,
      iev_enabled_check: false,
      compliance_control_name: "CompanyControl::NameIsPresent",
      control_attributes: control_attributes,
      compliance_check_set: compliance_check_set,
      criticity: criticity
  }

  before(:each){
    referential.switch do
      Chouette::Company.where(id: company.id).update_all(name: company_name)
      create :line, company: company, line_referential: line_referential
    end
  }

  context "when the company has a name" do
    it "should pass" do
      expect{compliance_check.process}.to change{ComplianceCheckResource.count}.by 1
      resource = ComplianceCheckResource.last
      expect(resource.status).to eq "OK"
    end
  end

  context "when the company has no name" do
    let(:company_name){ "" }

    context "when the criticity is warning" do
      let(:criticity){ "warning" }

      it "should set the status according to its params" do
        expect{compliance_check.process}.to change{ComplianceCheckResource.count}.by 1
        resource = ComplianceCheckResource.last
        expect(resource.status).to eq "WARNING"
      end

      it "should create a message" do
        expect{compliance_check.process}.to change{ComplianceCheckMessage.count}.by 1
        message = ComplianceCheckMessage.last
        expect(message.status).to eq "WARNING"
        expect(message.compliance_check_set).to eq compliance_check_set
        expect(message.compliance_check).to eq compliance_check
        expect(message.compliance_check_resource).to eq ComplianceCheckResource.last
      end
    end

    context "when the criticity is error" do
      it "should set the status according to its params" do
        expect{compliance_check.process}.to change{ComplianceCheckResource.count}.by 1
        resource = ComplianceCheckResource.last
        expect(resource.status).to eq "ERROR"
      end

      it "should create a message" do
        expect{compliance_check.process}.to change{ComplianceCheckMessage.count}.by 1
        message = ComplianceCheckMessage.last
        expect(message.status).to eq "ERROR"
        expect(message.compliance_check_set).to eq compliance_check_set
        expect(message.compliance_check).to eq compliance_check
        expect(message.compliance_check_resource).to eq ComplianceCheckResource.last
      end
    end
  end
end
