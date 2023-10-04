class MoviesController < ApplicationController
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # STEP 1: Redirect to appropriate route in special cases 

    ## note: params naturally uses form {"G" =>"1", "R" => "1"}, 
    ##       but session can only use array or string. We make session an array of params' keys.

    puts params[:ratings].instance_of?(Array)

    ## here, ratings_to_use is an array of ratings we want to filter with
    @ratings_to_use = params.has_key?(:ratings) ? (params[:ratings].instance_of?(Array) ? params[:ratings] : params[:ratings].keys) : \
    (session.has_key?(:ratings) ? session[:ratings] : Movie.all_ratings)

    sort_by_to_use = params.has_key?(:sort_by) ? params[:sort_by] : \
    (session.has_key?(:sort_by) ? session[:sort_by] : nil)

    puts(sort_by_to_use)

    if !params.has_key?(:ratings)
      ## redirect to the appropriate route 
      if sort_by_to_use == nil 
        ## :sort_by could be unspecified, 
        ## since user starts with not having selected ordering by
        ## title nor release_date
        redirect_to movies_path(:ratings => Movie.array_to_hash(@ratings_to_use))
      else
        redirect_to movies_path(:ratings => Movie.array_to_hash(@ratings_to_use), :sort_by => sort_by_to_use)
      end 
    end

    # Step 2. Filter movies accordingly & cache data in session 
    #         - we have params for ratings, and possibly sort_by

    # ## we always pass ratings as an array, not a hash with 1 values for filtering movies 
    # @ratings_array_of_keys = ratings_to_use.collect {|ind| ind[0]}

    ## get rid of "1" value at the end for querying by ratings filter 
    @movies = Movie.with_ratings(@ratings_to_use)
    @all_ratings = Movie.all_ratings

    if sort_by_to_use != nil 
      @movies = @movies.order(sort_by_to_use)
      session[:sort_by] = sort_by_to_use
    end
    
    session[:ratings] = @ratings_to_use
 
    ## Highlight the appropriate sorting method, if selected - params[:sort_by]
    @hilite_header_title = (sort_by_to_use == "title") ? 'hilite bg-warning' : ''
    @hilite_header_release_date = (sort_by_to_use == "release_date") ? 'hilite bg-warning' : ''
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
end
