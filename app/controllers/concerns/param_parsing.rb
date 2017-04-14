module ParamParsing
  # Calculate start and page num from URL params
  def page_calc(params)
    # Set page number from params
    pagenum = params[:page] ? params[:page].to_i : 1

    # Calculate start index for docs
    start = pagenum*30-30
    return pagenum, start
  end

  # Defines list of params to ignore when checking params of queries
  def params_to_ignore
    @params_to_ignore = ["utf8", "action", "controller", "page", "c", "a"]
  end

  # Parse the params for the search query
  def parse_search_query_params
    # Filter for only the params that aren't facets
    search_params = params.except(*@params_to_ignore).select{|param| !param.include?("_facet") && !param.include?("range_")}

    # Generate a query hash from params
    return search_params.inject({}) do |query_hash, param|
      # Parse search params
      field, doc_source = param[0].split("_source_")
      field, doc_source = "_all", "all_docs" if doc_source.blank?

      # Save val and field for query in hash divided by source
      (query_hash[doc_source]||= {})[field] = param[1]
      query_hash
    end.to_json
  end

  # Parse out dates
  def parse_range_params
    range_params = params.select{|k, v| k.include?("range_") && !v.blank?}

    # Make an array of items from the range hash
    return range_params.inject({}) do |range_hash, param|
      start_or_end, field = param[0].split("_source_")[0].split("range_")
      gte_or_lte = start_or_end == "start" ? :gte : :lte
      
      # Merge into hash
      (range_hash[field]||= {}).merge!({gte_or_lte => Date.strptime(param[1], "%m/%d/%Y")})
      range_hash
    end.to_json
  end

  # Parse params for facet
  def parse_facet_params
    # Get just the params that are facets
    facet_params = params.select{|k, v| k.include?("_facet")}

    # Remap the params
    return facet_params.inject([]) do |remapped, facet|
      # Handle all facets as arrays
      value_list = facet[1].is_a?(Array) ? facet[1] : [facet[1]]
      facet_name = facet[0].gsub("_facet", ".keyword")

      # Save param for each
      value_list.each{|facet_val| remapped.push({facet_name => facet_val})}
      remapped
    end.to_json
  end
end
