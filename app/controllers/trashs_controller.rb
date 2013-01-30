class TrashsController < ApplicationController
  def update
    trash = Trash.first
    trash.update_attributes!(params[:trash])
    render text: "OK"
  end
end