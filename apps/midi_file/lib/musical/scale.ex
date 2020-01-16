defmodule Musical.Scale do
  @notes [:C, :Cs, :D, :Ds, :E, :F, :Fs, :G, :Gs, :A, :As, :B]
  @flat_notes [:C, :Db, :D, :Eb, :E, :F, :Gb, :G, :Ab, :A, :Bb, :B]

  # Ionian
  @major [:t, :t, :s, :t, :t, :t]
  # Aeolian
  @minor [:t, :s, :t, :t, :s, :t]

  def semitones(:t), do: 2
  def semitones(:s), do: 1

  @doc """
  Example:
    iex> Musical.Scale.tonic(0)
    :C
  """
  def tonic(index), do: @notes |> Enum.at(index)

  @doc """
  Example:
    iex> Musical.Scale.note(0, :sharp)
    :C
    iex> Musical.Scale.note(0, :flat)
    :C
    iex> Musical.Scale.note(1, :sharp)
    :Cs
    iex> Musical.Scale.note(1, :flat)
    :Db
  """
  def note(index, :sharp), do: @notes |> Enum.at(index)
  def note(index, :flat), do: @flat_notes |> Enum.at(index)

  @doc """
  Example:
    iex> Musical.Scale.flat_or_sharp?(:C)
    :sharp
    iex> Musical.Scale.flat_or_sharp?(:Cs)
    :sharp
    iex> Musical.Scale.flat_or_sharp?(:Db)
    :flat
  """
  def flat_or_sharp?(note) do
    if Enum.any?(@notes, &(&1 == note)) do :sharp else :flat end
  end

  @doc """
  Example:
    iex> Musical.Scale.tonic_index(:C)
    0
  """
  def tonic_index(note) do
     Enum.find_index(@notes, &(&1 == note)) || Enum.find_index(@flat_notes, &(&1 == note))
   end

  @doc """
  Example:
    iex> Musical.Scale.scale_indexes(:C, :major)
    [0,2,4,5,7,9,11]

    iex> Musical.Scale.scale_indexes(:D, :major)
    [2,4,6,7,9,11,1]

    iex> Musical.Scale.scale_indexes(:Bb, :major)
    [2,4,5,7,9,10,0]
  """
  def scale_indexes(tonic, :major), do: scale_indexes(tonic, @major)

  @doc """
  Example:
    iex> Musical.Scale.scale_indexes(:C, :minor)
    [0,2,3,5,7,8,10]

    iex> Musical.Scale.scale_indexes(:D, :minor)
    [2,4,5,7,9,10,0]

    iex> Musical.Scale.scale_indexes(:Bb, :minor)
    [10, 0, 1, 3, 5, 6, 8]
  """
  def scale_indexes(tonic, :minor), do: scale_indexes(tonic, @minor)

  def scale_indexes(tonic, pattern) when is_list(pattern) do
    start_index = tonic_index(tonic)
    # IO.inspect(pattern, label: "pattern")
    # IO.inspect(tonic, label: "tonic")
    # IO.inspect(start_index, label: "start_index")
    pattern
    |> Enum.reduce([start_index], fn interval, [index | _tail] = list ->
      [rem(index + semitones(interval), 12) | list]
    end)
    |> Enum.reverse()
  end

  @doc """
  Example:
    iex> Musical.Scale.scale_notes(:C, :major)
    [:C,:D,:E,:F,:G,:A,:B]

    iex> Musical.Scale.scale_notes(:D, :major)
    [:D, :E, :Fs, :G, :A, :B, :Cs]

    iex> Musical.Scale.scale_notes(:Bb, :major)
    [:Bb, :C, :D, :Eb, :F, :G, :A]
  """
  def scale_notes(tonic, mode) do
    flat_or_sharp = flat_or_sharp?(tonic)
    scale_indexes(tonic, mode)
    |> Enum.map(&note(&1, flat_or_sharp))
  end

  @doc """
  Example:
    iex> Musical.Scale.scale_degree([:C,:D,:E,:F,:G,:A,:B], 59)
    %{degree: 7, note: :B, octave: 3}

    iex> Musical.Scale.scale_degree([:C,:D,:E,:F,:G,:A,:B], 60)
    %{degree: 1, note: :C, octave: 4}

    iex> Musical.Scale.scale_degree([:C,:D,:E,:F,:G,:A,:B], 61)
    %{degree: nil, note: :Cs, octave: 4}

    iex> Musical.Scale.scale_degree([:C,:D,:E,:F,:G,:A,:B], 62)
    %{degree: 2, note: :D, octave: 4}
  """
  def scale_degree(scale, midi) when is_list(scale) and is_integer(midi) do
    note = @notes |> Enum.at(rem(midi, 12))

    %{
      note: note,
      octave: floor(midi / 12) - 1,
      degree:
        case Enum.find_index(scale, &(&1 == note)) do
          nil -> nil
          index -> 1 + index
        end
    }
  end
end
