# frozen_string_literal: true

require 'git_tag_name_validator'

describe 'SemVer' do
  pattern = 'MAJOR.MINOR.PATCH'
  subject { GitTagNameValidator.new(scheme: pattern) }

  context ['0.0.0', '0.0.1', '0.1.0', '0.1.1'].join(' ') do
    output_msg = "\nAll local tags match a scheme of #{pattern}\n"

    before { allow_any_instance_of(GitTagNameValidator).to receive(:`).and_return(self.class.description) }

    it 'All tags match SemVer scheme' do
      expect { subject.execute }.to output(output_msg).to_stdout
    end
  end

  context ['0.0.0', '0.0.1', '0.1.1'].join(' ') do
    exception_msg = "0.1.1 does not match a scheme of #{pattern}: "\
      '1 is not a valid value for PATCH'\
      ' or the tag that should precede 0.1.1 does not exist.'

    before { allow_any_instance_of(GitTagNameValidator).to receive(:`).and_return(self.class.description) }

    it 'One or more tags do not match SemVer scheme' do
      expect { subject.execute }.to raise_error(an_instance_of(RuntimeError)
        .and(having_attributes(message: exception_msg)))
    end
  end
end

describe 'CalVer' do
  pattern = '0Y.0M.MICRO'
  subject { GitTagNameValidator.new(scheme: pattern) }

  context ['20.02.0', '21.10.0', '21.10.1', '22.03.0'].join(' ') do
    output_msg = "\nAll local tags match a scheme of #{pattern}\n"

    before { allow_any_instance_of(GitTagNameValidator).to receive(:`).and_return self.class.description }

    it 'All tags match CalVer scheme' do
      expect { subject.execute }.to output(output_msg).to_stdout
    end
  end

  context ['21.10.0', '22.02.15'].join(' ') do
    exception_msg = "22.02.15 does not match a scheme of #{pattern}: "\
      '15 is not a valid value for MICRO'\
      ' or the tag that should precede 22.02.15 does not exist.'

    before { allow_any_instance_of(GitTagNameValidator).to receive(:`).and_return self.class.description }

    it 'One or more tags do not match CalVer scheme' do
      expect { subject.execute }.to raise_error(an_instance_of(RuntimeError)
        .and(having_attributes(message: exception_msg)))
    end
  end
end
