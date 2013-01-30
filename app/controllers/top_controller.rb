class TopController < ApplicationController
  def index
    @blocks = Block.all
    @trash = Trash.first
    @canvas = Canvas.first
  end
end