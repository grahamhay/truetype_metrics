defmodule TruetypeMetricsTest do
  use ExUnit.Case
  doctest TruetypeMetrics

  @roboto     "test/fonts/Roboto/Roboto-Regular.ttf"
  @bitter     "test/fonts/Bitter/Bitter-Regular.ttf"

  #============================================================================
  # checksum

  test "checksum works - no padding" do
    # make sure it tests all the lengths needing padding
    assert TruetypeMetrics.checksum("ioaerpiuha3q23rhjlaiueyaiq34hfkjanglhadf") == 4058887661
  end

  test "checksum works, pad 3" do
    # make sure it tests all the lengths needing padding
    assert TruetypeMetrics.checksum("ioaerpiuha3q23rhjlaiueyaiq34hfkjanglhadfg") == 1491973613
  end

  test "checksum works, pad 2" do
    # make sure it tests all the lengths needing padding
    assert TruetypeMetrics.checksum("ioaerpiuha3q23rhjlaiueyaiq34hfkjanglhadfgh") == 1498789357
  end

  test "checksum works, pad 1" do
    # make sure it tests all the lengths needing padding
    assert TruetypeMetrics.checksum("ioaerpiuha3q23rhjlaiueyaiq34hfkjanglhadfghl") == 1498817005
  end
  
  test "checksum deals with an empty binary" do
    # make sure it tests all the lengths needing padding
    assert TruetypeMetrics.checksum("") == 0
  end

  #============================================================================
  # roboto

  test "loads the Roboto-Regular file" do
    {:ok, %FontMetrics{} = metrics} = TruetypeMetrics.load( @roboto )
    assert metrics.bounding_box == {-1509, -555, 3861, 2718}
    assert metrics.units_per_em == 2048
    assert metrics.smallest_ppem == 9
    assert metrics.direction == 2
    assert metrics.glyph_count == 1294
    refute metrics.kerning
    assert is_list(metrics.ranges)
    assert metrics.style == :bold

    assert metrics.source.signature_type == :sha256
    signature = :crypto.hash( :sha256, File.read!(@roboto) )
    |> Base.url_encode64(padding: false)
    assert metrics.source.signature == signature
    assert metrics.source.font_type == "TrueType"
  end

  test "parses the Roboto-Regular file" do
    font_data = File.read!( @roboto )
    {:ok, %FontMetrics{} = metrics} = TruetypeMetrics.parse( font_data )
    assert metrics.source.signature_type == :sha256
    signature = :crypto.hash( :sha256, font_data )
    |> Base.url_encode64(padding: false)
    assert metrics.source.signature == signature
  end

  #============================================================================
  # bitter - has a kerning table...

  test "loads the Bitter-Regular file" do
    {:ok, %FontMetrics{} = metrics} = TruetypeMetrics.load( @bitter )
    assert metrics.bounding_box == {-60, -265, 1185, 1200}
    assert metrics.units_per_em == 1000
    assert metrics.smallest_ppem == 9
    assert metrics.direction == 2
    assert metrics.glyph_count == 256
    assert metrics.kerning[{36, 52}] == {-15, 0}
    assert is_list(metrics.ranges)
    assert metrics.style == :bold

    assert metrics.source.signature_type == :sha256
    signature = :crypto.hash( :sha256, File.read!(@bitter) )
    |> Base.url_encode64(padding: false)
    assert metrics.source.signature == signature
    assert metrics.source.font_type == "TrueType"
  end

  test "parses the Bitter-Regular file" do
    font_data = File.read!( @bitter )
    {:ok, %FontMetrics{} = metrics} = TruetypeMetrics.parse( font_data )
    assert metrics.source.signature_type == :sha256
    signature = :crypto.hash( :sha256, font_data )
    |> Base.url_encode64(padding: false)
    assert metrics.source.signature == signature
  end


  #============================================================================
  # various failures

  test "Checks overall internal file hash" do
    font_data = File.read!( @bitter ) <> "extra data"
    assert TruetypeMetrics.parse( font_data ) == {:error, :invalid_file}
  end

end
