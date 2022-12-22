# frozen_string_literal: true

class Scheduler::SendMessageController < SchedulerController
  def show
    send_message_to_students_thirty_days_after_registration
    head :ok
  end

  private

  def send_message_to_students_thirty_days_after_registration
    @komagata = User.find_by(login_name: 'komagata')

    User.students.find_each do |student|
      next unless student.after_thirty_days_registration?

      @komagata.comments.create(
        description: I18n.t('send_message.description'),
        commentable_id: Talk.find_by(user_id: student.id).id,
        commentable_type: 'Talk'
      )
    end
  end
end
