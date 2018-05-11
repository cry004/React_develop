class HealthcheckController < ApplicationController
  def index
    render text: 'good'
  end

  def ssl_configured?
    false
  end
end
