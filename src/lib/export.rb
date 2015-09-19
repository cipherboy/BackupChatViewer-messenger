## BackupChatViewer-hangouts -- A Google Takeout Hangout.json parser for BackupChatViewer
## Copyright (C) 2015 Alexander Scheel <alexander.m.scheel@gmail.com>

require 'set'
require 'json'
require 'fileutils'
require 'date'

module Messenger
    class Export
        def initialize()
            @options = Hangouts.options()
            if File.exists?(@options.inpath)
                puts "Reading file into JSON object in memory..."
                temporary = File.read(@options.inpath)
                #@data = JSON.parse(temporary)
                temporary = nil
                GC.start()
            else
                puts "Missing input file #{@options.inpath}..."
                @data = nil
            end
        end

        def start()
            if @options.dry
                export_dry()
            else
                export()
            end
        end

        def export()
        end

        def export_dry()
        end

        def close()
        end
    end
end
