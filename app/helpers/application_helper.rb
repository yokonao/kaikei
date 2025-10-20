module ApplicationHelper
  def base_button_classes
    "block cursor-pointer disabled:cursor-not-allowed disabled:opacity-50"
  end

  def primary_button_classes(size: :md)
    cls = "#{base_button_classes} bg-black focus:bg-gray-700 text-white"
    case size
    when :lg
      cls += " py-4 px-12 text-xl tracking-widest"
    else
      cls += " py-2 px-4"
    end

    cls
  end

  def secondary_button_classes(size: :md)
    cls = "#{base_button_classes} bg-white focus:bg-black border-2 border-black text-black focus:text-white"

    case size
    when :lg
      cls += " py-4 px-12 text-xl tracking-widest"
    else
      cls += " py-2 px-6"
    end

    cls
  end
end
