defmodule Utility do

#  Converts Hex string to Equaivalent Decimal Values
  def hexToDec(h) when h >= "0" and h <= "9" do
      String.to_integer(h)
  end

  def hexToDec(h) when h >= "A" and h <= "F" do
      cond do
        h == "A" -> 10
        h == "B" -> 11
        h == "C" -> 12
        h == "D" -> 13
        h == "E" -> 14
        h == "F" -> 15
      end
  end

#  Finds which node is closer between Hash Value of Node 1 and Node 2
  def closerHash(current, hash1, hash2) do
    diff1 = hashdifference(current, hash1)
    diff2 = hashdifference(current, hash2)
    value = if diff1 < diff2 do
      hash1
    else
      hash2
    end
    value
  end

#  Calculates the Difference between Hash Values of two nodes
  defp hashdifference(hex1, hex2) do
    h1 = Atom.to_string(hex1)
    h2 = Atom.to_string(hex2)
    {int1,_} = Integer.parse(Atom.to_string(hex1), 16)
    {int2,_} = Integer.parse(Atom.to_string(hex2), 16)
    abs(int2 - int1)
  end

end
