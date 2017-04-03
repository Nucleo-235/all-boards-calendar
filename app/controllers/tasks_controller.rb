class TasksController < ApiController
  include ActionController::MimeResponds
  skip_before_action :authenticate_user!, only: [:calendar]
  before_action :set_task, only: [:show, :update, :destroy]

  # GET /tasks
  # GET /tasks.json
  # GET /tasks.ics
  def index
    if params[:retrieve].present? && to_boolean(params[:retrieve])
      ProjectDailySyncer.sync_user(current_user.id)
    end

    @tasks = Task.joins(:project).where(projects: { user_id: current_user.id })
    @tasks = @tasks.where(due_date: (params[:startDate]..params[:endDate]))
    @tasks = @tasks.order(:due_date)

    render json: @tasks
  end

  def calendar
    logger.info params
    user = current_user || User.find_by(uid: params[:uid])
    @tasks = Task.joins(:project).where(projects: { user_id: user.id })
    @tasks = @tasks.where(due_date: (params[:startDate]..params[:endDate])) if params[:startDate] && params[:endDate]
    @tasks = @tasks.order(:due_date)

    respond_to do |wants|
      wants.json do
        render json: @tasks
      end
      wants.ics do
        calendar = Icalendar::Calendar.new
        @tasks.each do |task|
          event = task.to_ics
          # puts event.to_json
          calendar.add_event(event) if event
        end
        calendar.publish
        render text: calendar.to_ical, content_type: 'text/calendar'
      end
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    render json: @task
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    if @task.save
      render json: @task, status: :created, location: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    @task = Task.find(params[:id])
    if @task.project.user.id != current_user.id
      head :forbidden
    elsif @task.update(task_params)
      head :no_content
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy

    head :no_content
  end

  private

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:project_id, :type, :name, :description, :due_date, :completed, :assigned, :trello_card_id)
    end
end
