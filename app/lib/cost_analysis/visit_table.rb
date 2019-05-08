require 'byebug'
module CostAnalysis

  class VisitLineItem
    attr_accessor :description, :unit_type, :service_rate, :applicable_rate, :subjects, :visit_counts

    def per_patient_total
      visit_counts.reduce(0.0) do |total, count|
        total + (count * applicable_rate)
      end
    end

    def total_visit_count
      visit_counts.sum
    end

    def per_study_total
      subjects * per_patient_total
    end
  end

  class VisitTable

    include ActionView::Helpers::NumberHelper

    VISIT_HEADERS = ["","Current","Your Price", "Subjects"]
    SUMMARY_HEADERS = ["","Current","Your Price", "Qty"]

    attr_accessor :arm_name, :line_items, :visit_labels

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

    def summarized_by_service
      table = TableWithGroupHeaders.new
      table.add_column_labels ([self.arm_name] + SUMMARY_HEADERS + ["Per Patient", "Per Study"])
      per_patient_total = 0.0
      per_study_total = 0.0
      cores.each do |core|
        table.add_header build_program_core_row(core, 7)
        @line_items[core].each do |li|
          per_study_total += li.per_study_total
          per_patient_total += li.per_patient_total
          table.add_data [li.description, li.unit_type, to_money(li.service_rate), to_money(li.applicable_rate), li.total_visit_count] + [to_money(li.per_patient_total), to_money(li.per_study_total)]
        end
      end
      table.add_summary [{content: "", colspan: 5}] + [to_money(per_patient_total), to_money(per_study_total)]
      table
    end

    def line_item_detail
      data = TableWithGroupHeaders.new
      data.add_column_labels self.build_header_row(0, visit_count)
      self.cores.each do |core|
        data.add_header self.build_program_core_row(core, 5 + visit_count)

        core_rows = self.build_line_item_rows(@line_items[core], 0, visit_count)
        data.concat(core_rows)
      end
      data.add_summary self.build_summary_row(0, visit_count, visit_count)
      data
    end

    def paged(visit_columns_per_page:, rows_per_page:)

      page_datas = []
      self.pages(visit_columns_per_page) do |page_num, page_size, visits_this_page|
        data = TableWithGroupHeaders.new

        data.add_column_labels self.build_header_row(page_num-1, page_size)

        self.cores.each do |core|
          data.add_header self.build_program_core_row(core, 5 + visits_this_page)

          core_rows = self.build_line_item_rows(@line_items[core], page_num - 1, page_size)
          data.concat(core_rows)
        end
        data.add_summary self.build_summary_row(page_num-1, page_size, visits_this_page)

        page_datas << data
      end

      current = nil
      Enumerator.new do |yielder|
        page_datas.each do |pd|
          yielder << pd
          # if pd.row_count + (current&.row_count || 0) <= rows_per_page
          #   current = pd.combine_with current
          # else
          #   byebug if current.nil?
          #   yielder << current
          #   current = pd
          # end
        end

        # yielder << current unless current.nil?
      end
    end

    def build_header_row(page_idx, page_size=nil)
      if page_idx == :all
        [self.arm_name] + VISIT_HEADERS + @visit_labels
      else
        [self.arm_name] + VISIT_HEADERS + @visit_labels.drop(page_idx*page_size).take(page_size)
      end
    end

    def build_program_core_row(program_or_core, colspan)
      [{:colspan => colspan, :content => program_or_core, :align => :left, :size => 16}]
    end

    def build_line_item_rows(line_items, page_idx, page_size)
      items = []
      line_items.each do |li|
        visit_counts = li.visit_counts.drop(page_idx*page_size).take(page_size)
        items << [li.description, li.unit_type, to_money(li.service_rate), to_money(li.applicable_rate), li.subjects] + visit_counts.map { |c| c == 0 ? "" : c.to_s }
      end
      items

    end

    def build_summary_row(page_idx, page_size, visits_this_page)
      summary_row = Array.new(visits_this_page,0)
      @line_items.each do |program_or_core, lines|

        lines.each do |li|

          visit_counts = li.visit_counts.drop(page_idx*page_size).take(visits_this_page)
          #count is maybe qty?
          #page_size is the number of visits we show in the table
          #don't forget about cents_to_dollars
          visit_counts.each_with_index do |count,idx|
            summary_row[idx] += (count * li.applicable_rate)
          end
        end
      end
      [{content: "Per Patient", colspan: 5}] + summary_row.map{ |x| to_money(x) }
    end

    def pages(visit_columns_per_page)
      pages_needed = visit_count.div(visit_columns_per_page)
      pages_needed += 1 if visit_count.remainder(visit_columns_per_page) > 0
      page_start = 1
      pages_needed.times do |p|
        visits_this_page = visit_labels.drop( (page_start-1) * visit_columns_per_page).take(visit_columns_per_page).size
        yield page_start, visit_columns_per_page, visits_this_page
        page_start += 1
      end
    end

    def to_money(v)
      number_with_precision(v, :precision => 2, :delimiter => ",")
    end
  end

end
