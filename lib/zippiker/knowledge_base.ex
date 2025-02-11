defmodule Zippiker.KnowledgeBase do
  use Ash.Domain

  # `resources` is a macro A.K.A DSL to indicate that this sections lists resources under this domain
  resources do
    resource Zippiker.KnowledgeBase.Category
    resource Zippiker.KnowledgeBase.Article
    resource Zippiker.KnowledgeBase.Tag
    resource Zippiker.KnowledgeBase.ArticleTag
    resource Zippiker.KnowledgeBase.Comment
    resource Zippiker.KnowledgeBase.ArticleFeedback
  end
end