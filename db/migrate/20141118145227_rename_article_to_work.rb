class RenameArticleToWork < ActiveRecord::Migration
  def up
    rename_table :articles, :works
    rename_column :alerts, :article_id, :work_id
    rename_column :api_responses, :article_id, :work_id
    rename_column :changes, :article_id, :work_id
    rename_column :retrieval_histories, :article_id, :work_id
    rename_column :tasks, :article_id, :work_id
    rename_column :traces, :article_id, :work_id

    change_column :agents, :kind, :string, default: "work"
  end

  def down
    rename_table :works, :articles
    rename_column :alerts, :work_id, :article_id
    rename_column :api_responses, :work_id, :article_id
    rename_column :changes, :work_id, :article_id
    rename_column :retrieval_histories, :work_id, :article_id
    rename_column :tasks, :work_id, :article_id
    rename_column :traces, :work_id, :article_id

    change_column :agents, :kind, :string, default: "article"
  end
end
