# デザイン統一のために CSS クラスの管理を担うクラス
class Designer
  def primary_button(size: :md)
    cls = "#{self.button_base} bg-black focus:bg-gray-700 text-white"
    case size
    when :lg
      cls += " py-4 px-12 text-xl tracking-widest"
    else
      cls += " py-2 px-4"
    end

    cls
  end

  def secondary_button(size: :md)
    cls = "#{self.button_base} bg-white focus:bg-black border-2 border-black text-black focus:text-white"

    case size
    when :lg
      cls += " py-4 px-12 text-xl tracking-widest"
    else
      cls += " py-2 px-6"
    end

    cls
  end

  private

  def button_base
    "block cursor-pointer disabled:cursor-not-allowed disabled:opacity-50"
  end
end
