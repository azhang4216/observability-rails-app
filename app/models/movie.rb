class Movie < ActiveRecord::Base
  def self.all_ratings
    # return Movie.distinct.pluck(:rating)
    return ['G','PG','PG-13','R'] 
  end 

  def self.all_ratings_as_hash
    return {"G"=>"1", "PG"=>"1", "PG-13"=>"1", "R"=>"1"}
  end

  def self.with_ratings(ratings)
    # takes an array of ratings (e.g. ["r", "pg-13"]) and 
    # returns an ActiveRecord relation of movies whose rating matches (case-insensitively) 
    # anything in that array
    return Movie.where(rating: ratings)
  end
end
