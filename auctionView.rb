#! /usr/bin ruby

#=======================================#
# auctionView                           #
# -----------                           #
# - class to display bidding histograms #
# Author: Mark Lewis                    #
#=======================================#
require 'rubygems'
require 'rubygame'
include Rubygame

class AuctionView
  def initialize
    width = 640
    height = 480
    ''' screen setup '''
    @screen = Screen.set_mode [width, height]
    @screen.title = 'Auction Histogram'
    @screen.fill [0,0,225]
    @screen.update
    ''' event queue setup '''
    @queue = EventQueue.new
    @auction_over = false
  end
  
  def displayHistogram mean stddev hist
    
    quitAuctionView
  end

  def quitAuctionView
    Rubygame.quit
  end
end
