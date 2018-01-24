defmodule Aernold do

  defp reduce_to_value({:int, int}, _state) do
    int
  end

  defp reduce_to_value({:string, string}, state) do
    string
  end

  defp reduce_to_value({:char, char}, state) do
    char
  end

  defp reduce_to_value({:hex, hex}, state) do
    hex
  end

  defp reduce_to_value({:id, id}, state) do
    id
  end

  defp reduce_to_value({:type, type}, state) do
    type
  end

  defp reduce_to_value({{op, _}, lhs, rhs}, state) do
    cond do
      op == "=" ->
        IO.inspect("Assign")
        lhs = reduce_to_value(lhs, state)
        rhs = reduce_to_value(rhs, state)
        Map.merge(state, %{lhs => rhs})
      op == "+" ->
        IO.inspect("ADD")
        reduce_to_value(lhs, state) + reduce_to_value(rhs, state)
      op == "-" ->
        IO.inspect("SUB")
        reduce_to_value(lhs, state) - reduce_to_value(rhs, state)
      op == "*" ->
        IO.inspect("MUL")
        reduce_to_value(lhs, state) * reduce_to_value(rhs, state)
      op == "/" ->
        IO.inspect("DIV")
        reduce_to_value(lhs, state) / reduce_to_value(rhs, state)
    end
  end

  # defp reduce_to_value({:add_op, lhs, rhs}, state) do
  #   reduce_to_value(lhs, state) + reduce_to_value(rhs, state)
  # end
  #
  # defp reduce_to_value({:sub_op, lhs, rhs}, state) do
  #   reduce_to_value(lhs, state) - reduce_to_value(rhs, state)
  # end
  #
  # defp reduce_to_value({:mul_op, lhs, rhs}, state) do
  #   reduce_to_value(lhs, state) * reduce_to_value(rhs, state)
  # end
  #
  # defp reduce_to_value({:div_op, lhs, rhs}, state) do
  #   reduce_to_value(lhs, state) / reduce_to_value(rhs, state)
  # end

  defp evaluate_ast([{lhs, _}, rhs | tail], state) do
    IO.puts "-----------------LHS------------------"
    IO.inspect(lhs)
    IO.puts "-----------------RHS----------------"
    IO.inspect(rhs)
    IO.puts "..................TAIL..................."
    IO.inspect(tail)
    rhs_value = reduce_to_value(rhs, state)
    evaluate_ast(tail, Map.merge(state, %{lhs => rhs_value}))
  end

  defp evaluate_ast([{op, lhs, rhs} | tail], state) do
    IO.puts "-----------------LHS------------------"
    IO.inspect(lhs)
    IO.puts "-----------------RHS----------------"
    IO.inspect(rhs)
    IO.puts "..................TAIL..................."
    IO.inspect(tail)
    lhs_value = reduce_to_value(lhs, state)
    IO.inspect(lhs_value)
    rhs_value = reduce_to_value(rhs, state)
    IO.inspect(rhs_value)
    evaluate_ast(tail, Map.merge(state, %{lhs_value => rhs_value}))
  end

  defp evaluate_ast([], state) do
    state
  end

  def process_ast(ast) do
    evaluate_ast(ast, %{})
  end

  def parse_string(string) do
    parse(string)
  end

  def parse_file(filename) do
    file = Path.absname("apps/aernold/" <> filename)
    {:ok, file_content} = File.read(file)
    parse(file_content)
  end

  defp parse(content) do
    with {:ok, tokens, _} <- :aernold_lexer.string(to_char_list(content)),
         {:ok, result} <- :aernold_parser.parse(tokens)
    do
      process_ast(result)
    else
      {:error, reason, _} ->
        reason
      {:error, {_, :aernold_lexer, reason}} ->
        to_string(reason)
    end
  end
end