module DocsHelper

  def sanitize_doc_content(content)
    "#{content}".html_safe
  end

  def renderize_doc_title(title_tag, original_title)
    title_tag.blank? ? original_title : title_tag
  end
end
