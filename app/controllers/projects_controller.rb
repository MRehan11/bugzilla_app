class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_projects, only: [:create, :index]
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "projects listing", :projects_path

  def index
  end

  def new
    add_breadcrumb "new project", new_project_path
    if !current_user.manager?
      flash[:alert] = "This action is not permitted"
      redirect_to projects_path
    end
    @project = Project.new
  end

  def create
    @project = current_user.created_projects.new(project_params)
    if @project.save
      flash[:success] = "Project Created"
      redirect_to projects_path
    else
      flash[:alert] = @project.errors.full_messages.to_sentence
      redirect_to projects_path
    end
  end

  def edit
    add_breadcrumb "project", project_path(@project)
    add_breadcrumb "edit project", edit_project_path
  end

  def update
    if !current_user.manager?
      flash[:alert] = "This action is not permitted"
      redirect_to projects_path
    end
    if @project.update(project_params)
      flash[:success] = "Project was updated successfully."
      redirect_to @project
    else
      render "edit"
    end

  end

  def destroy
    if @project.present?
      @project.destroy
      redirect_to projects_path
      flash[:success] = "Project was deleted successfully"
    else
      flash[:alert] = "Project not found"
    end  
  end

  def show
    add_breadcrumb "project", project_path(@project)
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, user_ids: [])
  end

  def set_projects
    if current_user.manager?||current_user.qa?
      @projects = Project.all
    else
      @projects = current_user.projects
    end
  end

  def set_project
    @project = Project.find_by(id: params[:id])
  end

end
