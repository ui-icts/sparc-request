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
      data.add_column_labels self.build_header_row
      self.cores.each do |core|
        data.add_header self.build_program_core_row(core, 5 + visit_count)

        core_rows = self.build_line_item_rows(@line_items[core])
        data.concat(core_rows)
      end
      data.add_summary self.build_summary_row()
      data
    end


    def build_header_row
      [{:colspan => 2, :content => self.arm_name},"Current","Your Price", "Subjects"] + @visit_labels
    end

    def build_program_core_row(program_or_core, colspan)
      [{:colspan => colspan, :content => program_or_core, :align => :left, :size => 16}]
    end

    def build_line_item_rows(line_items)
      line_items.map do |li|
        label_data = [
          li.description,
          li.unit_type,
          to_money(li.service_rate),
          to_money(li.applicable_rate),
          li.subjects
        ]
        label_data + li.visit_counts.map { |c| c == 0 ? "" : c.to_s }
      end
    end

    def build_summary_row
      summary_row = Array.new(visit_count,0)
      @line_items.each do |program_or_core, lines|
        lines.each do |li|
          li.visit_counts.each_with_index do |count,idx|
            summary_row[idx] += (count * li.applicable_rate)
          end
        end
      end
      [{content: "Per Patient", colspan: 5}] + summary_row.map{ |x| to_money(x) }
    end

    def to_money(v)
      number_with_precision(v, :precision => 2, :delimiter => ",")
    end
  end

end
