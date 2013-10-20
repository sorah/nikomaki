module FiscalDate
  class << self
    def locate(date_or_time)
      date = case date_or_time
             when Date
               date_or_time
             when Time
               date_or_time.to_date
             else
               raise TypeError, "`date_or_time' must be an Date or Time"
             end

      if Option[:month_starts] <= date.day
        month = FiscalDate::Month.new(date.year, date.month)
      else
        month = FiscalDate::Month.new(date.year, date.month - 1)
      end

      week = month.weeks.find { |w| w.range.cover?(date) }

      [week, month]
    end

    def today
      self.locate(Date.today)
    end

    def locate_week(*args)
      self.locate(*args).first
    end

    def locate_month(*args)
      self.locate(*args).last
    end

    def current_week
      self.today.first
    end

    def current_month
      self.today.last
    end
  end

  class Month
    def self.in(year)
      (1..12).map { |m| self.new(year, m) }
    end

    def initialize(y, m)
      @year, @month = y, m
    end

    attr_reader :year, :month

    def number; self.month; end

    def begin
      @begin ||= Date.new(@year, @month, Option[:month_starts])
    end

    def begin_in_time
      self.begin.beginning_of_day.localtime
    end

    def end
      @end ||= self.begin.next_month.change(day: Option[:month_starts]) - 1.day
    end

    def end_in_time
      self.end.end_of_day.localtime
    end

    def range
      self.begin .. self.end
    end

    def range_in_time
      self.begin_in_time ... (self.end + 1.day).beginning_of_day.localtime
    end

    def weeks
      Week.in self
    end

    def days
      self.range.to_a
    end

    def inspect
      "#<FiscalDate::Month(#{self.year}/#{self.month}): #{range.inspect}>"
    end

    def ==(o)
      o.class == self.class && [self.month, self.year] == [o.month, o.year]
    end
  end

  class Week
    def self.in(month)
      week_starts = Option[:week_starts]

      month.range.inject([]) do |result, day|
        result << [day, day] if result.empty? || day.wday == week_starts
        result.last[1] = day
        result
      end.map.with_index do |days, i|
        self.new(month, i.succ, days.first .. days.last)
      end
    end

    def initialize(fiscal_month, weekno, range)
      @number = weekno
      @month = fiscal_month
      @range = range
    end

    attr_reader :range, :month, :number
    def week() @number end

    def begin
      range.begin
    end

    def begin_in_time
      range.begin.beginning_of_day.localtime
    end

    def end
      range.end
    end

    def end_in_time
      range.end.end_of_day.localtime
    end

    def range_in_time
      self.begin_in_time ... (self.end + 1.day).beginning_of_day.localtime
    end

    def days
      range.to_a
    end

    def inspect
      "#<FiscalDate::Week(#{self.month.year}/#{self.month.month} Week #{self.number}): #{range.inspect}>"
    end

    def to_s
      "#{self.month.year}/#{self.month.number}: Week #{self.number} (#{range.inspect})"
    end

    def ==(o)
      o.class == self.class && \
        [self.number, self.month, self.range] \
          == [o.number, o.month, o.range]
    end
  end
end