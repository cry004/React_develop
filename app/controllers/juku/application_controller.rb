class Juku::ApplicationController < ApplicationController
  layout 'juku_application'

  protect_from_forgery with: :null_session
end
