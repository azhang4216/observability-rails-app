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

    # PART 1: RATINGS
    @ratings_to_show = []
   
    if params.has_key?(:ratings)
      @ratings_to_show = params[:ratings].keys
      @movies = @movies.with_ratings(params[:ratings].keys)
    end

    ## We hash the ratings so that we remember even after sorting by title or date
    session[:ratings] = @ratings_to_show
    @ratings_to_show_hash = Hash[@ratings_to_show.collect {|key| [key, '1']}]

    # PART 2: TITLE OR RELEASE DATE
    ## We account for the possibility that user has not picked to sort by title or release date
    if params.has_key?(:sort_by)
      if params[:sort_by] == "title"
        @movies = @movies.order(:title) 
      elsif params[:sort_by] == "release_date"
        @movies = @movies.order(:release_date)
      end
    end

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
end
