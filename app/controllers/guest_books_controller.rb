# encoding: utf-8

class GuestBooksController < AnonBoardController
  before_action :set_guest_book, only: [:show, :edit, :update, :destroy]

  def initialize(*params)
    super(*params)   
    @controller_name=t('activerecord.models.guest_book')
    @script="board/index"
    @meta_description='예쁘고 귀여운 수정이의 방명록입니다.'
    
    get_menu('guest_books')
  end
  
  # GET /guest_books
  # GET /guest_books.json
  def index
    @guest_books = GuestBook.order(@menu_setting.order).page(params[:page]).per(@menu_setting.per)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @guest_books }
    end
  end
  
  # GET /guest_books/1
  # GET /guest_books/1.json
  def show
    @guest_book_comments=@guest_book.guest_book_comment.order(@menu_setting.order).page(params[:page]).per(@menu_setting.per)
    @guest_book_comment=GuestBookComment.new
    
    @script="board/show"     
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @guest_book }
    end
  end
  
  # GET /guest_books/new
  # GET /guest_books/new.json
  def new
    @guest_book = GuestBook.new
    @guest_book.build_guest_book_content
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @guest_book }
    end
  end
  
  # GET /guest_books/1/edit
  def edit
  end
  
  # POST /guest_books
  # POST /guest_books.json
  def create
    @guest_book = GuestBook.new(guest_book_params)
    
    if current_user
      @guest_book.user_id=current_user.id
    end
    
    respond_to do |format|
      if Rails.env.production? 
        result=verify_recaptcha(:model => @guest_book, :message => "Oh! It's error with reCAPTCHA!") && @guest_book.save
      else 
        result=@guest_book.save
      end
      
      if result
        format.html { redirect_to @guest_book, :notice=> @controller_name +t(:message_success_create)}
        format.json { render :json => @guest_book, :status => :created, :location => @guest_book }
      else
        format.html { render :action => "new" }
        format.json { render :json => @guest_book.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /guest_books/1
  # PUT /guest_books/1.json
  def update
    respond_to do |format|
      if @guest_book.update_attributes(guest_book_params)
        format.html { redirect_to @guest_book, :notice=> @controller_name +t(:message_success_update)}
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @guest_book.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /guest_books/1
  # DELETE /guest_books/1.json
  def destroy
    @guest_book.destroy
    
    respond_to do |format|
      format.html { redirect_to guest_books_url }
      format.json { head :ok }
    end
  end
  
  protected
  
  def get_gg 
    return set_guest_book
  end
  
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_guest_book
    @guest_book = GuestBook.find(params[:id])
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def guest_book_params
    params.require(:guest_book).permit(:id,:name,:password,:title,guest_book_content_attributes: [:id,:content],guest_book_comment_attributes: [:id,:content])
  end
end
