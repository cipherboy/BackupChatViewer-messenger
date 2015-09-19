#!/usr/bin/env ruby
## BackupChatViewer-hangouts -- A Google Takeout Hangout.json parser for BackupChatViewer
## Copyright (C) 2015 Alexander Scheel <alexander.m.scheel@gmail.com>

require 'set'
require_relative "lib/options"
require_relative "lib/export"

module Messenger
    def self.start()
        @options = Messenger::Options.new(ARGV)
        Messenger::Options.new(['--help']) if ARGV.size == 0

        unless @options.dry
            unless Dir.exists?(@options.outdir)
                Dir.mkdir(@options.outdir)
            end
        end

        @options.tasks.each do |task|
            worker = nil
            if task == 'export'
                worker = Messenger::Export.new
            elsif task == 'list'
                worker = Messenger::List.new
            elsif task == 'accounts'
                worker = Messenger::Accounts.new
            end

            if worker
                worker.start
                worker.close
                GC.start
            end
        end
    end

    def self.options()
        return @options
    end
end

if __FILE__ == $0
    Hangouts.start()
end
