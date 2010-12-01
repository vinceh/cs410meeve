module EventsHelper
  def joined( jevents, id )    
    if (jevents.include?(id))
      return true
    else
      return false
    end
  end
end
