# frozen_string_literal: true

require 'git_tag_name_validator'

schemes = {
  cal_ver: {
    name: 'CalVer',
    pattern: '0Y.0M.MICRO'
  },
  sem_ver: {
    name: 'SemVer',
    pattern: 'MAJOR.MINOR.PATCH'
  }
}

describe schemes[:sem_ver][:name] do
  git_tag_string = '0.0.0 0.0.1 0.1.0 0.1.1'

  subject { GitTagNameValidator.new(scheme: schemes[:sem_ver][:pattern]) }

  context git_tag_string do
    before do
      allow_any_instance_of(GitTagNameValidator).to receive(:`).and_return(git_tag_string)
    end

    it "All tags match #{schemes[:sem_ver][:name]} scheme" do
      expect do
        subject.execute
      end.to output("\nAll local tags match a scheme of #{schemes[:sem_ver][:pattern]}\n").to_stdout
    end
  end
end

describe schemes[:cal_ver][:name] do
  git_tag_string = '20.02.0 21.10.0 21.10.1 22.03.0'

  subject { GitTagNameValidator.new(scheme: schemes[:cal_ver][:pattern]) }

  context git_tag_string do
    before do
      allow_any_instance_of(GitTagNameValidator).to receive(:`).and_return(git_tag_string)
    end

    it "All tags match #{schemes[:cal_ver][:name]} scheme" do
      expect do
        subject.execute
      end.to output("\nAll local tags match a scheme of #{schemes[:cal_ver][:pattern]}\n").to_stdout
    end
  end
end
