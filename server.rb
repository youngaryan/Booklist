require 'sinatra'
require 'mongoid'
require "sinatra/namespace"

Mongoid.load! "mongoid.config"

class Book
  include Mongoid::Document

  field :title, type: String
  field :author, type: String
  field :isbn, type: String

  validates :title, presence: true
  validates :author, presence: true
  validates :isbn, presence: true

  index({ title: 'text' })
  index({ isbn:1 }, { unique: true, name: "isbn_index" })

  scope :title, -> (title) { where(title: /^#{title}/) }
  scope :isbn, -> (isbn) { where(isbn: isbn) }
  scope :author, -> (author) { where(author: author) }
end

get '/' do
    'welcome to Booklist213'
end



namespace '/api/v1' do

  before do
    content_type 'application/json'
  end

  get '/books' do
    Book.all.to_json
  end
end


get '/books' do
  books = Book.all

  [:title, :isbn, :author].each do |filter|
    books = books.send(filter, params[filter]) if params[filter]
  end

  books.to_json
end