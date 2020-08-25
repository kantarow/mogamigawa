require 'natto'

class MogamigawaNode
  attr_reader :mecab_node

  def initialize(str, yomi, mecab_node=nil)
    @str = str
    @yomi = yomi
    @yomi_length = count_sounds @yomi
    @mecab_node = mecab_node
  end

  def to_s
    @str
  end

  def length
    @yomi_length
  end

  private

  def count_sounds(yomi)
    skip = ['ャ', 'ュ', 'ョ']
    count = 0

    yomi&.each_char do |c|
      count += 1 unless skip.include? c
    end

    count
  end
end

def build_mogamigawa_node(sentence)
  natto = Natto::MeCab.new
  node_enum = natto.enum_parse(sentence)
  node_enum.map do |mn|
    str = mn.surface
    yomi = mn.feature.split(',')[7]
    MogamigawaNode.new(str, yomi, mn)
  end
end

class Mogamigawa
  def initialize(sentence)
    @mogamigawa_node = build_mogamigawa_node(sentence)
    @offset = 0
  end

  def consume(target_len, allow_range=0)
    range = Range.new target_len, target_len + allow_range

    total_len = 0
    result = []

    @mogamigawa_node[@offset..-1].each do |mn|
      @offset += 1
      result << mn
      total_len += mn.length

      break if range.min <= total_len
    end

    unless range.cover? total_len
      raise RangeError.new "The range specified was (#{ range }), but the length of this sentence was #{ total_len }."
    end

    return result
  end

  def clear_offset
    @offset = 0
  end

  def set_offset(offset)
    @offset = offset
  end
end
