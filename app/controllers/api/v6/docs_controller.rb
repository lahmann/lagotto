class Api::V6::DocsController < Api::V6::BaseController
  def index
    docs = Doc.all
    @docs = DocDecorator.decorate(docs)
  end

  def show
    doc = Doc.find(params[:id])
    @doc = DocDecorator.decorate(doc)
  end
end
