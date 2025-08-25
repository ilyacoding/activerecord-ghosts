# frozen_string_literal: true

require "activerecord/ghosts/ghost_record"

module ActiveRecord
  module Ghosts
    module HasGhosts
      extend ActiveSupport::Concern

      class_methods do
        def has_ghosts(field_name, start: 1)
          include ActiveRecord::Ghosts::GhostRecord

          # ⚠️ Check index (leading column)
          unless connection.indexes(table_name).any? { |i| i.columns.first == field_name.to_s }
            warn "[activerecord-ghosts] ⚠️ Column :#{field_name} on #{table_name} has no leading index. " \
                 "Ghost queries may be slow."
          end

          define_singleton_method(:ghosts) do |*args, **opts|
            ghosts_implementation(all, field_name, start, *args, **opts)
          end

          define_method(:ghosts) do |*args, **opts|
            ghosts_implementation(self, field_name, start, *args, **opts)
          end
        end

        private

        def ghosts_implementation(relation, field_name, start, *args, **opts)
          range = extract_range(args, opts)

          # 1) No range → infinite Enumerator
          unless range
            return Enumerator.new do |yielder|
              n = start
              loop do
                batch_size = opts.fetch(:batch_size, 100)
                batch_range = (n...(n + batch_size))

                records = relation.where(field_name => batch_range).index_by(&field_name)
                defaults = relation.where_values_hash.symbolize_keys.merge(opts[:default] || {})

                batch_range.each do |num|
                  rec = records[num] || relation.new(defaults.merge(field_name => num))
                  rec._ghost = true unless records[num]
                  yielder << rec
                end

                n += batch_size
              end
            end
          end

          # 2) With range → fixed array
          records = relation.where(field_name => range).index_by(&field_name)
          defaults = relation.where_values_hash.symbolize_keys.merge(opts[:default] || {})

          range.map do |num|
            if records[num]
              records[num]
            else
              ghost = relation.new(defaults.merge(field_name => num))
              ghost._ghost = true
              ghost
            end
          end
        end

        def extract_range(args, opts)
          return args.first if args.first.is_a?(Range)
          return (opts[:from]..opts[:to]) if opts[:from] && opts[:to]

          nil
        end
      end
    end
  end
end
