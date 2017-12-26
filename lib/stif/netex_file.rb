module STIF
  class NetexFile

    CALENDAR_FILE_NAME = 'calendriers.xml'
    LINE_FILE_FORMAT   = %r{\A offre_ (?<line_object_id> .*?) _ .* \. xml \z}x
    XML_NAME_SPACE     = "http://www.netex.org.uk/netex"


    def initialize(file_name)
      @file_name = file_name
    end

    def frames
      frames = Hash.new { |h,k| h[k] = NetexFile::Frame.new(k) }
      Zip::File.open(@file_name) do |zipfile|
        zipfile.each do |entry|
          add_frame(to_frames: frames, from_entry: entry) if entry.ftype == :file
        end
      end
      frames.values
    end


    private

    def add_frame(to_frames:, from_entry:)
      entry_dir_name, entry_file_name = File.split(from_entry.name)

      if CALENDAR_FILE_NAME === entry_file_name
        from_entry.get_input_stream do |stream|
          to_frames[entry_dir_name].parse_calendars(stream.read)
        end
        return
      end

      line_file_match =  LINE_FILE_FORMAT.match( entry_file_name )
      if line_file_match
        to_frames[entry_dir_name].add_offer_file( line_file_match['line_object_id'])
      end
    end


    class Frame

      class << self
        def get_short_id file_name
          base_name = File.basename(file_name)
          STIF::NetexFile::LINE_FILE_FORMAT.match(base_name).try(:[], 'line_object_id')
        end
      end

      attr_accessor :name

      def initialize(name)
        @name = name
      end

      def parse_calendars(calendars)
        # <netex:ValidBetween>
        #  <netex:FromDate>2017-03-01</netex:FromDate>
        #  <netex:ToDate>2017-03-31</netex:ToDate>
        # </netex:ValidBetween>
        xml = Nokogiri::XML(calendars)
        xml.xpath("//netex:ValidBetween", "netex" => NetexFile::XML_NAME_SPACE).each do |valid_between|
          from_date = valid_between.xpath("netex:FromDate").try :text
          to_date = valid_between.xpath("netex:ToDate").try :text
          periods << Range.new(Date.parse(from_date), Date.parse(to_date))
        end
      end

      def add_offer_file(line_object_id)
        line_refs << line_object_id
      end

      def periods
        @periods ||= []
      end

      def line_refs
        @line_refs ||= []
      end

    end
  end
end
