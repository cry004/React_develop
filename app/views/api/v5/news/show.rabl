object @news

node(:id)        { @news.id }
node(:title)     { @news.title }
node(:content)   { @news.content }
node(:date)      { @news.published_at.to_s(:published_on) }
node(:image_url) { @news.news_photo&.resource_url }
