require 'byebug'

module CostAnalysis

  class TableWithGroupHeaders

    # header_rows and summary_rows are indices
    # into data that tell which rows are which
    attr_accessor :header_rows, :summary_rows, :data

    def initialize()
      @data = []
      @header_rows = []
      @summary_rows = []
    end

    def add_column_labels(row)
      @data << row
    end

    def add_header(row)
      @header_rows << @data.size
      @data << row
    end

    def add_data(row)
      @data << row
    end

    def concat(data_rows)
      @data.concat(data_rows)
    end

    def add_summary(row)
      @summary_rows << @data.size
      @data << row
    end

    def row_count
      @data.size
    end

    def table_rows
      @data
    end

    def combine_with(other)

      if other
        pad = self.data.size
        self.data += other.data
        self.header_rows += other.header_rows.map { |i| i + pad }
        self.summary_rows += other.summary_rows.map{ |i| i + pad }
      end
      self
    end

    def max_cols
      counts = []
      @data.each do |row|
        row_count = 0
        row.each do |col|
          if col.is_a?(Hash)
            row_count += col[:colspan].to_i
          else
            row_count += 1
          end
        end
        counts << row_count
      end
      counts.max
    end
    # header_cols & data_cols are args?
    def split(keep:, cols:)
      
      table_count = (self.max_cols-keep)/cols
      table_count += 1 if (self.max_cols-keep) % cols > 0

      tables = []
      table_count.times do
        t = TableWithGroupHeaders.new
        t.header_rows = self.header_rows
        t.summary_rows = self.summary_rows
        tables << t
      end

      self.data.each do |row|
        keep_cols = []
        keep_count = 0
        data_cols = Array.new(table_count) { Array.new }
        data_count = 0

        if row.size == 1 && row.first.is_a?(Hash)
          # single row we just resize the colspan
          tables.each do |table|
            colspan = [row.first[:colspan], keep+cols-1].min
            table.add_data [row.first.merge({:colspan => colspan})]
          end
          next
        end

        row.each do |col|

          if keep_count < keep
            if col.is_a?(Hash)
              keep_count += col[:colspan]
            else
              keep_count += 1
            end
            #we're keeping so add to each table
            #we'll copy header & summary indices later
            keep_cols << col
          else
            #it's a data column so figure out
            #which table it goes in
            table_idx = data_count/cols
            byebug if data_cols[table_idx].nil?
            data_cols[table_idx] << col
            data_count += 1
          end
        end
        data_cols.each_with_index do |table_cols,table_idx|
          tables[table_idx].add_data keep_cols + table_cols
        end
      end

      tables
      # times = 0
      # yielder = []
      # loop do
      #   start_idx = times * cols + keep
      #   break if start_idx >= column_limit
      #   other = TableWithGroupHeaders.new
      #   other.data = self.data.map do |row|
      #     keep_col = []
      #     keep_count = 0
      #     data_col = []
      #     data_count = 0
      #
      #     row.each do |col|
      #       if keep_count < keep
      #         keep_col << col
      #
      #         if col.is_a?(Hash)
      #           keep_count += col[:colspan]
      #         else
      #           keep_count += 1
      #         end
      #       elsif data_count < cols
      #
      #       end
      #     end
      #
      #     if row.size == 1 && row[0].is_a?(Hash)
      #       [row.first.merge({:colspan => cols})]
      #     else
      #       row[0,keep] + row[start_idx,cols]
      #     end
      #   end
      #   other.header_rows = self.header_rows
      #   other.summary_rows = self.summary_rows
      #
      #   yielder << other
      #   times += 1
      # end
      # yielder
    end

    def to_s
      col_size = 10
      s = []
      s += printable_header_lines(col_size)
      s += printable_data_rows(col_size)
      s += printable_summary_rows(col_size)
      s.join("\n")
    end

    private

    #These all need return arrays of strings
    def printable_header_lines(col_size=10)
      s = []
      s << ("-" * 140)
      s << column_label_row.map{ |c| c.center(col_size) }.join
      s << core_label_row.map{ |c| c[:content]}.join(" ")
      s
    end

    def printable_data_rows(col_size=10)
      data_rows.map{ |c|
        row = ""
        row += c[0].rjust(col_size)
        row += c[1..-1].map{ |ic| ic.to_s.center(col_size) }.join
        row
      }
    end

    def printable_summary_rows(col_size=10)
      row = ""
      header = summary_row[0]
      row += header[:content].ljust(col_size*header[:colspan])
      summary_row[1..-1].each do |c|
        row += c.to_s.center(col_size)
      end
      [row]
    end

    def column_label_row
      data[0]
    end

    def core_label_row
      data[1]
    end

    def data_rows
      data[2..-2]
    end

    def summary_row
      data[-1]
    end

  end

end
