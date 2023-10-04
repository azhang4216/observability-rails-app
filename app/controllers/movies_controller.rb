class MoviesController < ApplicationController
  # params: 
  #   sort_by = 'title', 'release_date' depending on which the user clicks

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all 
    @all_ratings = Movie.all_ratings

    # TODO: pass in the correct rating filters based on session hash

    # session[:uri] holds the correct uri



    # For example, if you just go to the root url (and not passing any parameters explicitly) but there is a session where the ratings and/or sort is saved, do you redirect (as the error is mentioning no/incorrect redirect) so that the query parameters show up with the values populated from the session in the URL?
    # if there is a session, we redirect to the appropriate url
    # if session.has_key?(:ratings) && !params.has_key?(:ratings)
    #   params[:ratings] = session[:ratings]
    #   redirect_to movies_path(:sort_by => "release_date", :ratings => @ratings_to_show_hash)
    #   return
    # end

    # PART 0: RESTful Routing
    ## Based on session (previous inputs) and params (current input),
    ## we create an appropriate path
    # restful_path = get_path_from_movie_parameters(request.query_parameters)
    
    # puts restful_path
    # puts request.query_parameters
    # puts request.fullpath
    
    # if restful_path != request.fullpath
    #   redirect_to movies_path(restful_path)
    #   return
    # end

    # if we are 
    # if request.path.key? :ratings && request[:ratings].keys.length = @all_ratings.length
    #   puts "sup boo"
    # end

    # if request.path == '{"ratings"=>{"G"=>"1", "PG"=>"1", "PG-13"=>"1", "R"=>"1"}, "sort_by"=>"title"}'
    #   redirect_to movies_path()  
    # end
    
    # puts request.query_parameters()
    # puts request.query_parameters() == '{"ratings"=>{"G"=>"1", "PG"=>"1", "PG-13"=>"1", "R"=>"1"}, "sort_by"=>"title"}'

    # puts request.query_parameters.has_key?(:ratings)
    # if !session.has_key?(:test)
    #   session[:test] = "1"
    #   redirect_to movies_path("/testing123/1234")
    #   return
    # end

    

    

    # @all_filters = [] # gives us the path

    # if !session.has_key?(:sort_by)
    #   redirect_to movies_path()
    # end

    # we populate all_filters 
    # if params.has_key?(:ratings)
    #   @all_filters

    


    ## Inconsistent redirected paths happen when 


    # if !(session.has_key?(:ratings) && session.has_key?(:sort_by))

    #   @all_ratings_hash = Hash[@all_ratings.collect {|key| [key, '1']}]

    # if !session.key?(:ratings) || !session.key?(:sort_by)
    #   @all_ratings_hash = Hash[@all_ratings.collect {|key| [key, '1']}]
    #   session[:ratings] = @all_ratings_hash if !session.key?(:ratings)
    #   session[:sort_by] = '' if !session.key?(:sort_by)
    #   redirect_to movies_path(:ratings => @all_ratings_hash, :sort_by => '') and return
    # end

    # PART 1: RATINGS
    @ratings_to_show = @all_ratings

    if !params.has_key?(:ratings) && session.has_key?(:ratings)
      # we use previously stored rating configurations
      puts "hello world 2"
      params[:ratings] = session[:ratings]
    end
   
    if params.has_key?(:ratings)
      puts "hello world 1"
      @ratings_to_show = params[:ratings]
      @movies = @movies.with_ratings(@ratings_to_show)
    end

    ## We hash the ratings so that we remember even after sorting by title or date
    session[:ratings] = params[:ratings]
    @ratings_to_show_hash = Hash[@ratings_to_show.collect {|key| [key, '1']}]

    # PART 2: TITLE OR RELEASE DATE
    ## We account for the possibility that user has not picked to sort by title or release date
    if params.has_key?(:sort_by)
      if params[:sort_by] == "title"
        @movies = @movies.order(:title) 
      elsif params[:sort_by] == "release_date"
        @movies = @movies.order(:release_date)
      end
    elsif session.has_key?(:sort_by)
      ## We use the saved sort_by options if user has selected, but we have refreshed
      params[:sort_by] = session[:sort_by]
    end

    ## We hash the title / release date so that we remember after refreshing
    session[:sort_by] = params[:sort_by]

    ## Highlight the appropriate sorting method, if selected
    @hilite_header_title = (params[:sort_by] == "title") ? 'hilite bg-warning' : ''
    @hilite_header_release_date = (params[:sort_by] == "release_date") ? 'hilite bg-warning' : ''
    
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def get_path_from_movie_parameters(query_parameters)
    # e.g. {"utf8"=>"✓", "ratings"=>{"G"=>"1", "PG"=>"1", "PG-13"=>"1", "R"=>"1"}, "commit"=>"Refresh"}
    restful_path = "/movies"

    # we specify specific ratings in uri if not all are checked
    if query_parameters.has_key?(:ratings) && query_parameters[:ratings].length < @all_ratings.length
      selected_ratings = query_parameters[:ratings].keys.sort.join("&") # alphabetized for consistent uri
      restful_path = "/ratings=" + selected_ratings
    end

    # we specify title or release date filter, if selected.
    if query_parameters.has_key?(:sort_by)
      restful_path = restful_path + "/sort_by=" + query_parameters[:sort_by]
    end

    return restful_path
  end
end
