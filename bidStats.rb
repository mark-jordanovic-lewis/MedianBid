#===================================#
# Randomised Auction Bidding System #
# --------------------------------- #
#                                   #
# Author: Mark Lewis                #
#===================================#
class BidData
  attr_reader :mean, :stddev # higher order dist moments define top/bottom sigma.
  def initialize
    @bids = Hash.new
    @changed_distribution = false
  end
  #=================================#
  # newBid                          #
  # ------                          #
  # - Adds a bid to the hash table  #
  # - record change in distribution #
  #=================================#
  def newBid name, bid
    if @bids.has_key?(name+"_4")
      return "Sorry, ", name, " but you've reached your maximum bids on this item."
    end
    name = name + "_0"
    while @bids.has_key?(name)
      name = name[0,name.size-1] + (name[-1,1].to_i + 1).to_s
    end
    @bids[name] = bid
    @changed_distribution = true
    return "You, ", name[0, name.size-2].to_s, " have bid ", bid.to_s, " on item."
  end
  #=================================#
  # bidders                         #
  # -------                         #
  # - removes duplicate bidder name #
  #   entries                       #
  # - returns individual bidders    #
  #=================================#
  def bidders
    bidders = Array.new{}
    @bids.keys.each{|name|
      if name.last == 0
        bidders << name[0,name.size - 3]
      end
    }
    return bidders
  end
  #============================#
  # histogram                  #
  # ---------                  #
  # - if the bids have changed #
  #   build the histogram      #
  # - return the histogram     #
  #============================#
  def histogram
    if @changed_distribution
      stat = Stats.new
      @mean   = stat.mean @bids
      @stddev = stat.stddev @mean, @bids
      @bid_distribution = stat.binHistogram @bids
      @changed_distribution = false
    end
    return @bid_distribution
  end
end


# ^____________________________________________________________________^ #


#=======================#
# Bidding Stats Methods #
# --------------------- #
#=======================#
# mean
# ----
class Stats
  def initialize 
  end
  def mean bids
    mean = 0
    bids.each{|name, bid| mean += bid}
    return mean/bids.size
  end
  # stddeviation
  # ------------
  def stddev mean, bids
    stddev = 0
    bids.each{|name, bid| 
      data = bid-mean
      stddev += data*data
    }
    return Math::sqrt stddev/bids.size
  end
  # binHistogram
  # ------------
  # - Hardcoded number of bins
  # - max and min as bounding variables
  # - bin centre as lable
  # ------------
  def binHistogram bids
    n_bins    = 15
    bid_vs    = bids.values
    max       = bid_vs.max
    min       = bid_vs.min
    histogram = Hash.new
    bin_width = (max-min)/n_bins
    a_half = bin_width/2
    (0..n_bins).each{|i| histogram[min+i*bin_width] =0 } # -a_half] = 0} # for low counts we get negatives...
    bid_vs.each{|v| 
      histogram.keys.each{|k| if v < k+a_half
                                histogram[k] += 1 
                                break
                              end 
      }
    }
    return histogram
  end
end
