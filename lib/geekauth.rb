module BggTools
  class GeekAuth
    class << self
      def set(session_id)
        @session_id = session_id
      end

      def get
        raise unless @session_id
        @session_id
      end
    end
  end
end
