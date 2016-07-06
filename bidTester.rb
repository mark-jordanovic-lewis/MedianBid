#=================================#
# Monte Carlo Item Auction - MCIA #
# ------------------------
# Test module for Bidding Engine  #
# ---------                       #
# bob = MCIA.new <n_punters>      #
# bob.openShop                    #
# bob.auctionItem    <---+--\     #
# bob.auctionStats       |  |     #
# bob.newItem        <---/  |     #
# bob.newPunters            |     #
# bob.openShop       <------/     #
# ------------                    #
# Author: Mark Lewis              #
#=================================#

#require 'auctionView'
require './bidStats'

class MCIA 
  attr_reader :auction_item, :punters
  def initialize n
    @wealth = 400
    @spread = 150
    @name_chars = (0..36).map{|i| i.to_s 36}
    @name_chars << " "
    @n_bidders = n
    newPunters
  end
  #========================#
  # Resetting the Auction  #
  # ---------------------  #
  # - newPunters           #
  #   Reset @punters.      #
  #   Calls openShop.      #
  #                        #
  # - takeSeats            # <--- '''Get your stats before running this one.'''
  #   Clears bid history   #
  #   of @punters.         #
  #   Renew BidData object #
  #========================#
  def newPunters
    # @punters : {('name', [cash, last_bid]), (...), (...)}
    @punters = Hash.new
    openShop
  end
  def newItem
    @punters.each{|k,v| @punters[k][1] = 0 }
    @auction_item = BidData.new
  end
  #===================================#
  # Betting Shop Control              #
  # --------------------              #
  # - openShop                        #
  #   Sets up punters with:           #
  #       ['name', [cash, last_bid]]. #
  #   Calls newItem.                  #
  #                                   #
  # - auctionItem                     #
  #   Histogram construction testing. #
  #   Hard coded betting rounds.      #
  #   max/min based on punters        #
  #   cash and previous bets.         #
  #===================================#
  def openShop
    @n_bidders.times{
      name = ""
      rand(5..9).times{
        name << @name_chars[rand(36)]
      }
      @punters[name] = if rand() > 0.49 then [@wealth + rand((@spread/3)).ceil, nil]
                       else                  [@wealth - rand((2*@spread)).floor, nil]
                       end
    }
    newItem
    print "Shop's open!\n"
  end
  def auctionItem
    n_rounds = 20
    n_rounds.times{
      bid = 0
      bidder_num = rand(@n_bidders)
      curr_bidder = @punters.keys[bidder_num]
      if @punters[curr_bidder][0] <= 0 then next end
      bid = if not @punters[curr_bidder][1] then rand(10..100)
            elsif  rand() > 0.4            then @punters[curr_bidder][1] + rand(10..80)
            else                                 @punters[curr_bidder][1] - rand(5..60)
            end
      if bid < 0 then bid = -1*bid end
      if bid > @punters[curr_bidder][0] then bid = @punters[curr_bidder][0] end
      @punters[curr_bidder][0] -= bid
      @punters[curr_bidder][1] = bid
      print @auction_item.newBid curr_bidder, bid
    }
    return "Bidding is closed. Thank you.\n"
  end
  #===============================#
  # auctionStats                  #
  # ------------                  #
  # returns:                      #
  #     [mean, stddev, histogram] #
  #===============================#
  def auctionStats
    if @punters.empty? then return "Aution has not started yet." end
    hist = @auction_item.histogram
    return [@auction_item.mean, @auction_item.stddev, hist]
  end
end

#================#
# bob the tester #
#================#
@bob = MCIA.new 30

def run
  @bob.auctionItem
end

def stats
  @bob.auctionStats
end

def completeBet
  got_money = true
  while got_money
    @bob.auctionItem
    got_money = false
    @bob.punters.each{|k,v|
      if v[0] > 0
        got_money = true
        break
      end
    }
    @bob.auctionItem
    puts @bob.auctionStats
  end
end

def clear
  @bob.newPunters
end
