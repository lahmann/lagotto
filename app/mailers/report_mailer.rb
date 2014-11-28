class ReportMailer < ActionMailer::Base
  default :from => ENV['ADMIN_EMAIL']

  def send_error_report(report)
    return if report.users.empty?

    @reviews = Review.daily_report
    mail(to: report.users.map(&:email).join(","), subject: "[#{ENV['SITENAME']}] Error Report")
  end

  def send_fatal_error_report(report, message)
    return if report.users.empty?

    @message = message
    mail(to: report.users.map(&:email).join(","), subject: "[#{ENV['SITENAME']}] Fatal Error Report")
  end

  def send_status_report(report)
    return if report.users.empty?

    @status = Status.new

    mail(to: report.users.map(&:email).join(","), subject: "[#{ENV['SITENAME']}] Status Report")
  end

  def send_work_statistics_report(report)
    return if report.users.empty?

    @works_count = Status.new.works_count

    mail(to: ENV['ADMIN_EMAIL'],
         bcc: report.users.map(&:email).join(","),
         subject: "[#{ENV['SITENAME']}] Article Statistics Report")
  end

  def send_stale_source_report(report, source_ids)
    return if report.users.empty?

    @sources = Source.where(id: source_ids).all
    mail(to: report.users.map(&:email).join(","), subject: "[#{ENV['SITENAME']}] Stale Source Report")
  end

  def send_missing_workers_report(report)
    return if report.users.empty?

    @workers_count = Worker.count

    mail(to: report.users.map(&:email).join(","), subject: "[#{ENV['SITENAME']}] Missing Workers Report")
  end
end
