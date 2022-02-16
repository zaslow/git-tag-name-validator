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

  def self.date_part_validator(range, tag_part)
    zero_padded_date_parts = range.to_a.map { |int_val| int_val.to_s.rjust(2, '0') }

    zero_padded_date_parts.include? tag_part
  end

  private_class_method :date_part_validator

  def self.numeric_validator(existing_tag_parts, tag_part)
    tag_part_int = tag_part.to_i
    expected_tag_part = (tag_part_int - 1).to_s

    # Strings converted to integers are 0
    tag_part == '0' || (tag_part_int.positive? && existing_tag_parts.include?(expected_tag_part))
  end

  private_class_method :numeric_validator

  def self.scheme_validators
    month_validator_lamda = lambda do |_existing_tag_parts, tag_part|
      GitTagNameValidator.send(:date_part_validator, (0..12), tag_part)
    end

    year_validator_lamda = lambda do |_existing_tag_parts, tag_part|
      GitTagNameValidator.send(:date_part_validator, (0..99), tag_part)
    end

    numeric_validator_lambda = lambda do |existing_tag_parts, tag_part|
      GitTagNameValidator.send(:numeric_validator, existing_tag_parts, tag_part)
    end

    {
      '0M' => month_validator_lamda,
      '0Y' => year_validator_lamda,
      'MAJOR' => numeric_validator_lambda,
      'MICRO' => numeric_validator_lambda,
      'MINOR' => numeric_validator_lambda,
      'PATCH' => numeric_validator_lambda
    }
  end

  private_class_method :scheme_validators

  private # instance methods

  def existing_tag_parts(current_tag, tag_part_index)
    prev_index = tag_part_index - 1
    matching_sub_versions = @tags.select do |existing_tag|
      tag_part_index.zero? || (
        existing_tag.split('.')[prev_index] == current_tag.split('.')[prev_index]
      )
    end

    matching_sub_versions.map { |match| match.split('.')[tag_part_index] }
  end

  def validate_tag(tag)
    tag_parts = tag.split('.')
    no_match_exception_msg = "#{tag} does not match a scheme of #{@scheme}"

    raise no_match_exception_msg unless @scheme.split('.').length == tag_parts.length

    index = 0
    while index < tag_parts.size # while loop is faster than each_with_index
      validate_tag_part(tag, index, no_match_exception_msg)
      index += 1
    end
  end

  def validate_tag_part(tag, tag_part_index, exception_msg)
    scheme_part = @scheme.split('.')[tag_part_index]
    tag_part = tag.split('.')[tag_part_index]

    return if @scheme_validators[scheme_part].call(existing_tag_parts(tag, tag_part_index), tag_part)

    raise "#{exception_msg}: #{tag_part} is not a valid value for #{scheme_part}"\
      " or the tag that should precede #{tag} does not exist."
  end
end
