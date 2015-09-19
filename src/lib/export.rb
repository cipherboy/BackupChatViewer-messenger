## BackupChatViewer-messenger -- A Google Takeout Hangout.json parser for BackupChatViewer
## Copyright (C) 2015 Alexander Scheel <alexander.m.scheel@gmail.com>

require 'set'
require 'nokogiri'
require 'fileutils'
require 'time'
require 'digest'
require 'securerandom'

module Messenger
    class Export
        def initialize()
            @options = Messenger.options()
            if File.exists?(@options.inpath)
                puts "Reading file into HTML object in memory..."
                temporary = File.open(@options.inpath)
                @data = Nokogiri::HTML(temporary)
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
            if @data.nil?
                return
            end

            puts "Parsing for conversations, users"
            convs = Set.new
            users = Set.new

            puts "Writing messages.csv"
            # conv_id,event_id,sender_id,message_id,segment_id,message_time,segment_type,segment_content
            messages_file = File.new(@options.outdir + '/messages.csv', 'w')
            messages_file.write "conv_id,event_id,sender_id,message_id,segment_id,message_time,segment_type,segment_content" + "\n"
            @data.css('div.thread').each do |thread|
                tusers = Set.new
                thread.each('span.user') do |user|
                    u = { name: user.text, chat_id: Digest::MD5.hexdigest(user.text.downcase), gaia_id: Digest::MD5.hexdigest(user.text.downcase) }
                    users.add(u)
                    tusers.add(u)
                end
                conv_id = Digest::MD5.hexdigest tusers.to_a.to_s
                people_id = []

                tusers.each do |tuser|
                    people_id.push tuser.chat_id
                end

                thread.css('div.message').each_with_index do |div, index|
                    event_id = SecureRandom.uuid
                    sender_id = Digest::MD5.hexdigest(div.css('span.user').text.downcase)
                    message_id = index
                    segment_id = 0
                    message_time = facebook_to_date(div.css('span.meta'))
                    segment_type = "TEXT"
                    segment_content = div.next_sibling.text

                    messages_file.write '"' + conv_id.to_s + '","' + event_id.to_s + '","' + sender_id.to_s + '","' + message_id.to_s + '","' + segment_id.to_s + '","' + message_time.to_s + '","' + segment_type.to_s + '","' + segment_content.to_s.gsub('"', '""') + '"' + "\n"
                end

                convs.add({conv_id: conv_id, people_id: people_id.join(':')})
            end
            messages_file.close()

            puts "Writing conversations.csv"
            # conv_id,people_ids
            conv_file = File.new(@options.outdir + '/conversations.csv', 'w')
            conv_file.write "conv_id,people_ids" + "\n"
            convs.each do |conv|
                conv_file.write '"' +conv[:conv_id] + '","' + conv[:people_ids] + '"' + "\n"
            end
            conv_file.close()

            puts "Writing people.csv"
            # chat_id,gaia_id,name
            people = Set.new
            people_file = File.new(@options.outdir + '/people.csv', 'w')
            people_file.puts "chat_id,gaia_id,name" + "\n"
            users.each do |person|
                people_file.write '"' + person[:chat_id] + '","' + person[:gaia_id] + '","' + person[:name] + '"' + "\n"
            end
            people_file.close()
        end

        def export_dry()
        end

        def facebook_to_date(input)
            return Time.Parse(input).strftime('%Y-%m-%d %H:%M:%S')
        end


        def close()
        end
    end
end
