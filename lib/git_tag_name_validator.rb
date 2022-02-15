# frozen_string_literal: true

require 'date'

# Main class for gem
class GitTagNameValidator
  def initialize(scheme:)
    @tags = `git tag --list`.split
    @numeric_validator = lambda do |existing_tag_parts, tag_part|
      tag_part_int = tag_part.to_i
      expected_tag_part = (tag_part_int - 1).to_s

      # Strings converted to integers are 0
      tag_part == '0' || (tag_part_int.positive? && existing_tag_parts.include?(expected_tag_part))
    end

    @scheme = scheme
    @scheme_validators = scheme_validators
  end

  def execute
    split_tag(@scheme).each do |scheme_part|
      raise "#{scheme_part} is not a supported scheme component" unless @scheme_validators.keys.include? scheme_part
    end

    @tags.each { |tag| validate_tag tag }

    puts "\nAll local tags match a scheme of #{@scheme}"
  end

  def self.scheme_validators
    today = Date.today

    {
      '0M' => ->(_existing_tag_parts, tag_part) { tag_part == today.strftime('%m') },
      '0Y' => ->(_existing_tag_parts, tag_part) { tag_part == today.strftime('%y') },
      'MAJOR' => @numeric_validator,
      'MICRO' => @numeric_validator,
      'MINOR' => @numeric_validator,
      'PATCH' => @numeric_validator
    }
  end

  def self.split_tag(tag)
    tag.split('.')
  end

  def self.validate_tag(tag)
    tag_parts = split_tag(tag)
    no_match_exception_msg = "#{tag} does not match a scheme of #{@scheme}"

    raise no_match_exception_msg unless split_tag(@scheme).length == tag_parts.length

    tag_parts.each_with_index { |tag_part, index| validate_tag_part(tag_part, index) }
  end

  def self.validate_tag_part(tag_part, index)
    scheme_part = split_tag(@scheme)[index]
    existing_tag_parts = @tags.map { |existing_tag| split_tag(existing_tag)[index] }

    return if @scheme_validators[scheme_part].call(existing_tag_parts, tag_part)

    raise "#{no_match_exception_msg}: #{tag_part} is not a valid value for #{scheme_part}"\
      " or the tag that should precede #{tag} does not exist."
  end
end
