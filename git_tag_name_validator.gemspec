# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.authors               = ['Dean Zaslow']
  spec.description           = 'Validates whether git tags conform to a given scheme'
  spec.email                 = 'dean.zaslow@adhocteam.us'
  spec.executables           = ['git_tag_name_validator']
  spec.files                 = ['lib/git_tag_name_validator.rb']
  spec.homepage              = 'https://rubygems.org/gems/git_tag_name_validator'
  spec.name                  = 'git_tag_name_validator'
  spec.required_ruby_version = '>= 2.5.0'
  spec.summary               = 'Git Tag Name Validator'
  spec.version               = '0.1.3'
end
