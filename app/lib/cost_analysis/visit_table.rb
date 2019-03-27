module CostAnalysis

  class VisitLineItem
    attr_accessor :description, :unit_type, :service_rate, :applicable_rate, :subjects, :visit_counts
  end

  class VisitPageData
    attr_accessor :data, :header_rows, :summary_rows

    def initialize(data, header_rows, summary_rows)
      @data = data
      @header_rows = header_rows
      @summary_rows = summary_rows
    end

    def to_s
      col_size = 10
      s = []
      s += printable_header_lines(col_size)
      s += printable_data_rows(col_size)
      s += printable_summary_rows(col_size)
      s.join("\n")
    end

    #These all need return arrays of strings
    def printable_header_lines(col_size=10)
      s = []
      s << ("-" * 140)
      s << data[0].map{ |c| c.center(col_size) }.join
      s << data[1].map{ |c| c[:content]}.join(" ")
      s
    end

    def printable_data_rows(col_size=10)
      data[2..-2].map{ |c|
        row = ""
        row += c[0].rjust(col_size)
        row += c[1..-1].map{ |ic| ic.to_s.center(col_size) }.join
        row
      }
    end

    def printable_summary_rows(col_size=10)
      row = ""
      header = data[-1][0]
      row += header[:content].ljust(col_size*header[:colspan])
      data[-1][1..-1].each do |c|
        row += c.to_s.center(col_size)
      end
      [row]
    end
  end

  class VisitTable

    STATIC_HEADERS = ["","","Current","Your Price", "Subjects"]
    VISITS_PER_PAGE = 14
    attr_accessor :line_items, :visit_labels

    def initialize
      visit_count = 60
      @visit_labels = []
      @line_items = {}
      nursing = "Nursing Services > Clinical Research Unit > ICTS > UIOWA (0003)"
      lab = "Lab > Clinical Research Unit > ICTS > UIOWA (0002)"

      @line_items[nursing] = []
      @line_items[lab] = []

      ["Bundle: Level 1","Height and Weight","Blood Draw/ Venipuncture (Adult)", "Urine Collection"].each do |service|
        li = VisitLineItem.new
        li.description = service
        li.unit_type = "First"
        li.service_rate = 50.0
        li.applicable_rate = 35.0
        li.subjects = 50
        li.visit_counts = Array.new(visit_count) { rand(0...3) }
        @line_items[nursing] << li
      end

      ["Sample Processing: Level A", "Sample Processing: Urine", "Dry Ice"].each do |service|
        li = VisitLineItem.new
        li.description = service
        li.unit_type = "Sample"
        li.service_rate = 50.0
        li.applicable_rate = 35.0
        li.subjects = 6
        li.visit_counts = Array.new(visit_count) { rand(0...3) }
        @line_items[lab] << li
      end

      visit_count.times do |c|
        @visit_labels << "Visit #{c+1}"
      end
    end

    def cores
      @line_items.keys
    end

    def visit_count
      @visit_labels.size
    end

    def pages
      pages_needed = visit_count.div(VISITS_PER_PAGE)
      pages_needed += 1 if visit_count.remainder(VISITS_PER_PAGE) > 0
      page_start = 1
      pages_needed.times do |p|
        yield page_start, VISITS_PER_PAGE
        page_start += 1
      end
    end

    def paged(visit_columns_per_page:, rows_per_page:)

      Enumerator.new do |yielder|
        self.pages do |page_num, page_size|
          data = []
          header_rows = []
          summary_rows = []
          headers = true

          self.cores.each do |core|
            core_rows = self.line_item_arr(core, headers: headers, page:page_num, page_size: page_size)
            if headers
              header_rows << data.size + 1
            else
              header_rows << data.size
            end
            data.concat(core_rows)
            summary_rows << (data.size - 1)
            headers = false
          end
          pd = 
          yielder << VisitPageData.new(data,header_rows,summary_rows)
        end
      end
    end
    def line_item_arr(program_or_core, headers: true, page: 1, page_size: 14)
      items = []
      page_idx = page - 1
      if headers
        items << STATIC_HEADERS + @visit_labels.drop(page_idx*page_size).take(page_size)
        # items << [{:colspan => 2, :content => program_or_core}] + ["Current","Your Price", "Subjects"] + @visit_labels.drop(page_idx*page_size).take(page_size)
      else
      end

      items << [{:colspan => (5 + page_size), :content => program_or_core, :align => :left, :size => 16}]
      summary_row = Array.new(page_size,0)
      @line_items[program_or_core].each do |li|
        visit_counts = li.visit_counts.drop(page_idx*page_size).take(page_size)
        #count is maybe qty?
        #page_size is the number of visits we show in the table
        #don't forget about cents_to_dollars
        visit_counts.each_with_index do |count,idx|
          summary_row[idx] += (count * li.applicable_rate)
        end
        items << [li.description, li.unit_type, li.service_rate, li.applicable_rate, li.subjects] + visit_counts.map { |c| c == 0 ? "" : c.to_s }
      end

      items << [{content: "Per Patient", colspan: 5}] + summary_row
      items
    end

  end

end
