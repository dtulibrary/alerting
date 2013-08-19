class AlertsController < ApplicationController
  # GET /alerts
  # GET /alerts.json
  def index
    @alerts = []
    if params[:user_id]
      if params[:alert_type] && params[:alert_type] == "journal"
        @alerts = Alert.journals(params[:user_id])
      elsif params[:alert_type] && params[:alert_type] == "search"
        @alerts = Alert.searches(params[:user_id])
      else
        @alerts = Alert.for_user(params[:user_id])
      end
    else
      @alerts = Alert.all
    end
    render json: @alerts
  end

  # GET /alerts/1
  # GET /alerts/1.json
  def show
    @alert = Alert.find(params[:id])

    render json: @alert
  end

  # GET /alerts/find
  # GET alerts/find.json
  def find    
    if(!params["find"].nil?)
      @alert = Alert.where(params["find"]).first
      if @alert
        render json: @alert
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :not_found
    end
  end

  # POST /alerts
  # POST /alerts.json
  def create
    @alert = Alert.new(params[:alert])

    if @alert.save
      render json: @alert, status: :created, location: @alert
    else
      render json: @alert.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /alerts/1
  # PATCH/PUT /alerts/1.json
  def update
    @alert = Alert.find(params[:id])

    if @alert.update_attributes(params[:alert])
      head :no_content
    else
      render json: @alert.errors, status: :unprocessable_entity
    end
  end

  # DELETE /alerts/1
  # DELETE /alerts/1.json
  def destroy
    @alert = Alert.find(params[:id])
    @alert.destroy

    head :no_content
  end

end
