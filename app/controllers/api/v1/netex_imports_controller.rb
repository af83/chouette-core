module Api
  module V1
    class NetexImportsController < ChouetteController

      def create
        respond_to do | format |
          format.json do 
            referential = Referential.find(netex_import_params[:referential_id])

            @import = NetexImport.create(netex_import_params.merge({
              workbench_id: referential.workbench_id
            }))

            unless @import.valid?
              render json: {errors: @import.errors}, status: 406
            end
          end
        end
      end


      private

      def netex_import_params
        params
          .require('netex_import')
          .permit(:file, :name, :referential_id)
      end
    end
  end
end
