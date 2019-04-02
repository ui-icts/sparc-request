module CostAnalysis

  class VisitLineItem
    attr_accessor :description, :unit_type, :service_rate, :applicable_rate, :subjects, :visit_counts
  end

  class VisitTable

    STATIC_HEADERS = ["","","Current","Your Price", "Subjects"]

    attr_accessor :line_items, :visit_labels

    def self.sample
      visit_count = 60
      nursing = "Nursing Services > Clinical Research Unit > ICTS > UIOWA (0003)"
      lab = "Lab > Clinical Research Unit > ICTS > UIOWA (0002)"

      ["Bundle: Level 1","Height and Weight","Blood Draw/ Venipuncture (Adult)", "Urine Collection"].each do |service|
        li = VisitLineItem.new
        li.description = service
        li.unit_type = "First"
        li.service_rate = 50.0
        li.applicable_rate = 35.0
        li.subjects = 50
        li.visit_counts = Array.new(visit_count) { rand(0...3) }
        add_line_item nursing, li
      end

      ["Sample Processing: Level A", "Sample Processing: Urine", "Dry Ice"].each do |service|
        li = VisitLineItem.new
        li.description = service
        li.unit_type = "Sample"
        li.service_rate = 50.0
        li.applicable_rate = 35.0
        li.subjects = 6
        li.visit_counts = Array.new(visit_count) { rand(0...3) }
        add_line_item lab, li
      end

      visit_count.times do |c|
        @visit_labels << "Visit #{c+1}"
      end

    end

    def initialize
      @visit_labels = []
      @line_items = {}
    end

    def add_line_item(program_or_core, line_item)
      @line_items[program_or_core] = [] unless @line_items.has_key?(program_or_core)
      @line_items[program_or_core] << line_item
    end

    def cores
      @line_items.keys
    end

    def visit_count
      @visit_labels.size
    end

    def paged(visit_columns_per_page:, rows_per_page:)

      page_datas = []
      self.pages(visit_columns_per_page) do |page_num, page_size|
        data = VisitPageData.new

        data.add_data self.build_header_row(page_num-1, page_size)

        self.cores.each do |core|
          data.add_header self.build_program_core_row(core, page_size)

          core_rows = self.build_line_item_rows(@line_items[core], page_num - 1, page_size)
          data.concat(core_rows)
        end
        data.add_summary self.build_summary_row(page_num-1, page_size)

        page_datas << data
      end

      current = nil
      Enumerator.new do |yielder|
        page_datas.each do |pd|
          if pd.row_count + (current&.row_count || 0) <= rows_per_page
            current = pd.combine_with current
          else
            yielder << current
            current = pd
          end
        end

        yielder << current unless current.nil?
      end
    end

    def build_header_row(page_idx, page_size)
      STATIC_HEADERS + @visit_labels.drop(page_idx*page_size).take(page_size)
    end

    def build_program_core_row(program_or_core, page_size)
      [{:colspan => (5 + page_size), :content => program_or_core, :align => :left, :size => 16}]
    end

    def build_line_item_rows(line_items, page_idx, page_size)
      items = []
      line_items.each do |li|
        visit_counts = li.visit_counts.drop(page_idx*page_size).take(page_size)
        items << [li.description, li.unit_type, li.service_rate, li.applicable_rate, li.subjects] + visit_counts.map { |c| c == 0 ? "" : c.to_s }
      end
      items

    end

    def build_summary_row(page_idx, page_size)
      summary_row = Array.new(page_size,0)
      @line_items.each do |program_or_core, lines|

        lines.each do |li|

          visit_counts = li.visit_counts.drop(page_idx*page_size).take(page_size)
          #count is maybe qty?
          #page_size is the number of visits we show in the table
          #don't forget about cents_to_dollars
          visit_counts.each_with_index do |count,idx|
            summary_row[idx] += (count * li.applicable_rate)
          end
        end
      end
      [{content: "Per Patient", colspan: 5}] + summary_row
    end

    def summarized_by_service
      data = VisitPageData.new

    end

    def pages(visit_columns_per_page)
      pages_needed = visit_count.div(visit_columns_per_page)
      pages_needed += 1 if visit_count.remainder(visit_columns_per_page) > 0
      page_start = 1
      pages_needed.times do |p|
        yield page_start, visit_columns_per_page
        page_start += 1
      end
    end

  end

end
