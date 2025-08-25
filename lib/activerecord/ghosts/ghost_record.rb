# frozen_string_literal: true

module ActiveRecord
  module Ghosts
    module GhostRecord
      extend ActiveSupport::Concern

      included do
        attr_accessor :_ghost
      end

      def ghost?
        !!_ghost
      end

      def inspect
        base = super
        ghost? ? base.sub("#<", "#<ghost ") : base
      end
    end
  end
end
