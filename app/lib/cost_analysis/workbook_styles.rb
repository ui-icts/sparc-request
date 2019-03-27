module CostAnalysis

  class WorkbookStyles

    BLUE_BG = "C5D9F1"
    GRAY_BG = "E8E8E8"

    def initialize(wb)
      @styles = {}
      @styles[:study_information_header] = wb.styles.add_style(
        b: true,
        sz: 12,
        bg_color: BLUE_BG
      )

      @styles[:row_header_style] = wb.styles.add_style b: true, wrap_text: true, sz: 10

      @styles[:org_hierarchy_header] = wb.styles.add_style(
        b: true,
        sz: 10,
        bg_color: GRAY_BG
      )

      @styles[:visit_summary_row_header] = wb.styles.add_style(
        b: true,
        sz: 10,
        alignment: {
          horizontal: :right
        }
      )

      @styles[:table_header_style] = wb.styles.add_style sz: 10, b: true,   alignment: { horizontal: :center, wrap_text: true}
      @styles[:default] = wb.styles.add_style alignment: { horizontal: :left }

      @styles[:money] = wb.styles.add_style(
        b: false,
        sz: 10,
        format_code: '$* #,##0',
        border: Axlsx::STYLE_THIN_BORDER
      )

      @styles[:money_total] = wb.styles.add_style(
        b: true,
        sz: 10,
        format_code: '$* #,##0_)',
        border: Axlsx::STYLE_THIN_BORDER
      )
      
      @styles[:service_cost_money] = wb.styles.add_style(
        b: false,
        sz: 10,
        format_code: '$* #,##0.00_)',
      )

      @styles[:visit_header] = wb.styles.add_style(
        sz: 10,
        b: true,
        alignment: {horizontal: :center, wrap_text: true},
        border: Axlsx::STYLE_THIN_BORDER,
        bg_color: BLUE_BG
      )

      @styles[:visit_count] = wb.styles.add_style(
        sz: 10,
        b: false,
        alignment: {horizontal: :center},
        border: Axlsx::STYLE_THIN_BORDER,
      )

      @styles[:spacer_row] = wb.styles.add_style(
        sz: 10,
        b: false,
        bg_color: GRAY_BG
      )
    end

    def method_missing(id)
      @styles[id] or raise "No workbook style #{id}"
    end
  end

end
