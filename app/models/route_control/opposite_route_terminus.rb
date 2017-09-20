module RouteControl
  class OppositeRouteTerminus < ComplianceControl

    @@default_criticity = :warning
    @@default_code = "3-Route-5"

    after_initialize do
      self.name = self.class.name
      self.code = @@default_code
      self.criticity = @@default_criticity
    end
  end
end