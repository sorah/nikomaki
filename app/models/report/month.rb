class Report
  class Month
    include Report::Common

    def initialize(*args)
      case args.size
      when 2
        @fiscal_month = FiscalDate::Month.new(*args) # year, month
      when 1
        unless args.first.kind_of?(FiscalDate::Month)
          raise TypeError, "passed object is not FiscalDate::Month"
        end

        @fiscal_month = args.first
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
      end
    end

    attr_reader :fiscal_month

    def year() @fiscal_month.year end
    def month() @fiscal_month.month end

    def budget
      Category.total_budget(year, month)
    end

    def expenses
      Expense.in(@fiscal_month)
    end

    def weeks
      @fiscal_month.weeks.map { |fw| Report::Week.new(fw) }
    end

    def days
      @fiscal_month.days.map { |fd| Report::Day.new(fd) }
    end
  end
end