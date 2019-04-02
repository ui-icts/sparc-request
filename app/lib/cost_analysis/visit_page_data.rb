module CostAnalysis

  class VisitPageData
    attr_accessor :data, :header_rows, :summary_rows

    def initialize(data = nil, header_rows = nil, summary_rows = nil)
      @data = data || []
      @header_rows = header_rows || []
      @summary_rows = summary_rows || []
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

    def combine_with(other)

      if other
        pad = self.data.size
        self.data += other.data
        self.header_rows += other.header_rows.map { |i| i + pad }
        self.summary_rows += other.summary_rows.map{ |i| i + pad }
      end
      self
    end
    def to_s
      col_size = 10
      s = []
      s += printable_header_lines(col_size)
      s += printable_data_rows(col_size)
      s += printable_summary_rows(col_size)
      s.join("\n")
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
  end

end
