class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]
  before_action :is_admin?, only: [:show, :index, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /routes
  # GET /routes.json
  def index
    @routes = Route.order("name")
  end

  # GET /routes/1
  # GET /routes/1.json
  def show
    unless @route
      redirect_to '/'
    end
  end

  # GET /routes/new
  def new
    @route = Route.new
  end

  # GET /routes/1/edit
  def edit
  end

  # POST /routes
  # POST /routes.json
  def create
    @route = Route.new(route_params)

    respond_to do |format|
      if @route.save
        format.html { redirect_to @route, notice: 'Route was successfully created.' }
        format.json { render :show, status: :created, location: @route }
      else
        format.html { render :new }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /routes/1
  # PATCH/PUT /routes/1.json
  def update
    if params[:trigger] == "true"
      user_id = params[:user_id]
      route_id = params[:id]
      day = params[:day]
      @employee = User.find_by(id: user_id)
      @route = Route.find_by(id: route_id)
      @route.employee = params[:reset] ? nil : @employee
      @route.day = day
      @route.save
      respond_to do |format|
        format.html { redirect_to "/", notice: 'Route was successfully updated.' }
        format.json { render :show, status: :ok, location: @route }
      end
    else
      ## To keep the original logic, adding a trigger variable to AJAX request
      ## when coming from 'The Grid' to differentiate.
      employee_id = params[:route][:employee_ids][1..-1]
      employee_id.each do |id|
        @route.employees << User.find_by(id: id)
      end
      respond_to do |format|
        if @route.update(route_params)
          format.html { redirect_to "/", notice: 'Route was successfully updated.' }
          format.json { render :show, status: :ok, location: @route }
        else
          format.html { render :edit }
          format.json { render json: @route.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /routes/1
  # DELETE /routes/1.json
  def destroy
    @route.destroy
    respond_to do |format|
      format.html { redirect_to routes_url, notice: 'Route was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @route = Route.find_by(id: params[:id])
    end

    def is_admin?
      unless current_user && current_user.admin?
        flash[:error] = "You must be an administrator in to access this section"
        redirect_to "/" # halts request cycle
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def route_params
      params.require(:route).permit(:name, :description, :employee_ids)
    end
end
