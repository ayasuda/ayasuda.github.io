return {
  {
    Link = function (elm)
      if elm.target:find('^/.*$') then
        return pandoc.Link(elm.content, "/pages"..elm.target..".html", elm.title, elm.attr)
      else
        return elm
      end
    end
  }

}
