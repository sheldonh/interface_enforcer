require 'spec_helper'

describe TestInterface::Enforcer do

  let(:real_subject) {
    class Subject
      def ask; @knowledge || "the default"; end
      def tell(something); @knowledge = something; end
      private; def private_method; "a secret"; end
    end
    Subject.new
  }

  it "contracted methods are delegated to the subject" do
    subject = TestInterface::Enforcer.new(:ask => :allowed, :tell => :allowed).wrap(real_subject)
    subject.tell("new knowledge")
    subject.ask.should eq("new knowledge")
  end

  it "contracted methods honour subject privacy" do
    subject = TestInterface::Enforcer.new(private_method: :allowed).wrap(real_subject)
    expect { subject.private_method }.to raise_error(NoMethodError)
  end

  it "uncontracted methods raise a method violation" do
    subject = TestInterface::Enforcer.new(demand: :allowed).wrap(real_subject)
    expect { subject.ask }.to raise_error(TestInterface::MethodViolation)
  end

  it "contracted return value types are allowed" do
    subject = TestInterface::Enforcer.new(ask: { returns: String }).wrap(real_subject)
    subject.ask.should eq("the default")
  end

  it "uncontracted return value types raise a return violation" do
    subject = TestInterface::Enforcer.new(ask: { returns: Numeric }).wrap(real_subject)
    expect { subject.ask }.to raise_error(TestInterface::ReturnViolation)
  end

  it "contracted return values matching rules are allowed" do
    subject = TestInterface::Enforcer.new(ask: { returns: ->(o) { o.include?('default') } }).wrap(real_subject)
    subject.ask.should eq("the default")
  end

  it "return values that violate a return value contract rule raise a return violation" do
    subject = TestInterface::Enforcer.new(ask: { returns: ->(o) { o.include?('impossible') } }).wrap(real_subject)
    expect { subject.ask }.to raise_error(TestInterface::ReturnViolation)
  end

end
