defprotocol Dayron.Requestable do

  def from_json(value, data, opts)

  def url_for(value, opts)
end

defimpl Dayron.Requestable, for: Atom do
  def from_json(module, data, opts) do
    try do
      module.__from_json__(data, opts)
    rescue
      UndefinedFunctionError -> raise_protocol_exception(module)
    end
  end

  def url_for(module, opts) do
    try do
      module.__url_for__(opts)
    rescue
      UndefinedFunctionError -> raise_protocol_exception(module)
    end
  end

  defp raise_protocol_exception(module) do
    message = if :code.is_loaded(module) do
      "the given module is not a Rest.Model"
    else
      "the given module does not exist"
    end

    raise Protocol.UndefinedError,
         protocol: @protocol,
            value: module,
      description: message
  end
end
