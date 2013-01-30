# -*- coding: utf-8 -*-
namespace :db do
  desc "Initialize the position of the Trash box" 
   task :set_trash_box => :environment do
    Trash.destroy_all
    Trash.create!(x: 340, y: 340)
  end
end
