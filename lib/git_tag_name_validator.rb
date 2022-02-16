# frozen_string_literal: true

require 'date'

# Main class for gem
class GitTagNameValidator
  def initialize(scheme:)
    @scheme = scheme
    @scheme_validators = GitTagNameValidator.send :scheme_validators
    @tags = `git tag --list`.split
  end

  def execute
    @scheme.split('.').each do |scheme_part|
      raise "#{scheme_part} is not a supported scheme component" unless @scheme_validators.keys.include? scheme_part
    end

    @tags.each { |tag| validate_tag tag }

    puts "\nAll local tags match a scheme of #{@scheme}"
  end

  def self.date_validator(tag_part, date_expression)
    tag_part == Date.today.strftime(date_expression)
  end

  private_class_method :date_validator

  def self.numeric_validator(existing_tag_parts, tag_part)
    tag_part_int = tag_part.to_i
    expected_tag_part = (tag_part_int - 1).to_s

    # Strings converted to integers are 0
    tag_part == '0' || (tag_part_int.positive? && existing_tag_parts.include?(expected_tag_part))
  end

  private_class_method :numeric_validator

  def self.scheme_validators
    numeric_validator_lambda = lambda do |existing_tag_parts, tag_part|
      GitTagNameValidator.send(:numeric_validator, existing_tag_parts, tag_part)
    end

    {
      '0M' => ->(_existing_tag_parts, tag_part) { GitTagNameValidator.send(:numeric_validator, tag_part, '%m') },
      '0Y' => ->(_existing_tag_parts, tag_part) { GitTagNameValidator.send(:numeric_validator, tag_part, '%y') },
      'MAJOR' => numeric_validator_lambda,
      'MICRO' => numeric_validator_lambda,
      'MINOR' => numeric_validator_lambda,
      'PATCH' => numeric_validator_lambda
    }
  end

  private_class_method :scheme_validators

  private # instance methods

  def validate_tag(tag)
    tag_parts = tag.split('.')
    no_match_exception_msg = "#{tag} does not match a scheme of #{@scheme}"

    raise no_match_exception_msg unless @scheme.split('.').length == tag_parts.length

    index = 0
    while index < tag_parts.size # while loop is faster than each_with_index
      validate_tag_part(tag_parts[index], index, no_match_exception_msg)
      index += 1
    end
  end

  def validate_tag_part(tag_part, tag_part_index, exception_msg)
    scheme_part = @scheme.split('.')[tag_part_index]
    existing_tag_parts = @tags.map { |existing_tag| existing_tag.split('.')[tag_part_index] }

    return if @scheme_validators[scheme_part].call(existing_tag_parts, tag_part)

    raise "#{exception_msg}: #{tag_part} is not a valid value for #{scheme_part}"\
      " or the tag that should precede #{tag} does not exist."
  end
end
