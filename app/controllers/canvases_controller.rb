class CanvasesController < ApplicationController
  def update
    canvas = Canvas.first
    canvas.update_attributes!(params[:canvas])
    render text: "OK"
  end
end