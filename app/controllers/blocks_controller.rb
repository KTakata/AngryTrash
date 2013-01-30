class BlocksController < ApplicationController
  def create
    block = Block.create!(params[:block])
    render text: block.id #block.idを使わないとうまくいかない.
  end

  def update
    block = Block.find(params[:id])
    block.update_attributes!(params[:block])
    render text: "Successfully updated"
  end

  def destroy
    block = Block.find(params[:id])
    block.destroy #TODO:respond_to使う
    render text: "Successfully deleted"
  end

  def destroy_all
    Block.destroy_all
    render text: "Successfully deleted"
  end
end