class Admin::NewsController < Admin::ResourcesController
  after_action  :publish,         only: %i(create update)
  before_action :set_news_params, only: %i(create update)

  def create
    @item = @resource.new
    @item.assign_attributes(item_params_for_create)

    set_attributes_on_create

    image = params.dig(:news_photo, :image)
    @item.build_news_photo.image = image if image

    respond_to do |format|
      if @item.save
        format.html { redirect_on_success }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: 'new' }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    image = params.dig(:news_photo, :image)
    @item.build_news_photo.image = image if image
    super
  end

  private

  def publish
    return if @item.invalid? # publish only when save successfully
    published_at = @item.published_at
    floated_time = published_at.to_f # serialize for ActiveJob
    NewsPublicationJob.set(wait_until: published_at)
                      .perform_later(news_id:      @item.id,
                                     published_at: floated_time)
  end

  def fields
    action = params[:action]
    fields = @resource.typus_fields_for(action)
    case action
    when 'index' then fields.merge('image' => :dragonfly)
    else fields
    end
  end

  def set_news_params
    params[:news][:prefecture_codes] = params[:news][:prefecture_codes]&.split(',')
    params[:news][:member_types] ||= []
    params[:news][:gknn_cds] = params[:news][:gknn_cds].presence&.map(&:split)&.flatten
  end

  helper_method :fields

  module Admin::Resources::DataTypes::DragonflyHelper
    def typus_dragonfly_preview(news, _)
      return unless (preview = news.image)
      return unless (thumb   = news.image_thumbnail)
      render 'admin/templates/dragonfly_preview',
             preview: preview.remote_url,
             thumb:   thumb.remote_url
    end
  end
end
