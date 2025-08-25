# frozen_string_literal: true

require "active_support"
require "active_support/concern"
require "active_record"

require "activerecord/ghosts/version"
require "activerecord/ghosts/has_ghosts"

module ActiveRecord
  module Ghosts
  end
end

ActiveRecord::Base.include ActiveRecord::Ghosts::HasGhosts
