require 'spec_helper'
require 'htmlbeautifier'

module TableBuilderHelper
  include Pundit
end

describe TableBuilderHelper, type: :helper do
  describe "#table_builder_2" do
    it "builds a table" do
      referential = build_stubbed(:referential)
      workbench = referential.workbench

      # user_context = create_user_context(
      #   user: build_stubbed(:user),
      #   referential: referential
      # )
      user_context = OpenStruct.new(
        user: build_stubbed(
          :user,
          organisation: referential.organisation,
          permissions: [
            'referentials.create',
            'referentials.edit',
            'referentials.destroy'
          ]
        ),
        context: { referential: referential }
      )
      allow(helper).to receive(:current_user).and_return(user_context)

      referentials = [referential]

      allow(referentials).to receive(:model).and_return(Referential)

      allow(helper).to receive(:params).and_return({
        controller: 'workbenches',
        action: 'show',
        id: referentials[0].workbench.id,

        # These are added by WorkbenchesController#query_params
        q: {
          archived_at_not_null: 1,
          archived_at_null: 1
        }
      })

      expected = <<-HTML
<table class="table has-filter has-search">
    <thead>
        <tr>
            <th>
                <div class="checkbox"><input type="checkbox" name="0" id="0" value="all" /><label for="0"></label></div>
            </th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;q%5Barchived_at_not_null%5D=1&amp;q%5Barchived_at_null%5D=1&amp;sort=name">Nom<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;q%5Barchived_at_not_null%5D=1&amp;q%5Barchived_at_null%5D=1&amp;sort=status">Etat<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;q%5Barchived_at_not_null%5D=1&amp;q%5Barchived_at_null%5D=1&amp;sort=organisation">Organisation<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;q%5Barchived_at_not_null%5D=1&amp;q%5Barchived_at_null%5D=1&amp;sort=validity_period">Période de validité englobante<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;q%5Barchived_at_not_null%5D=1&amp;q%5Barchived_at_null%5D=1&amp;sort=lines">Lignes<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;q%5Barchived_at_not_null%5D=1&amp;q%5Barchived_at_null%5D=1&amp;sort=created_at">Créé le<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;q%5Barchived_at_not_null%5D=1&amp;q%5Barchived_at_null%5D=1&amp;sort=updated_at">Edité le<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;q%5Barchived_at_not_null%5D=1&amp;q%5Barchived_at_null%5D=1&amp;sort=published_at">Intégré le<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <div class="checkbox"><input type="checkbox" name="#{referential.id}" id="#{referential.id}" value="#{referential.id}" /><label for="#{referential.id}"></label></div>
            </td>
            <td title="Voir"><a href="/referentials/#{referential.id}">#{referential.name}</a></td>
            <td>
                <div class='td-block'><span class='sb sb-lg sb-preparing'></span><span>En préparation</span></div>
            </td>
            <td>#{referential.organisation.name}</td>
            <td>-</td>
            <td>#{referential.lines.count}</td>
            <td>#{I18n.localize(referential.created_at, format: :short)}</td>
            <td>#{I18n.localize(referential.updated_at, format: :short)}</td>
            <td></td>
            <td class="actions">
                <div class="btn-group">
                    <div class="btn dropdown-toggle" data-toggle="dropdown"><span class="fa fa-cog"></span></div>
                    <ul class="dropdown-menu">
                        <li><a href="/referentials/#{referential.id}">Consulter</a></li>
                        <li><a href="/referentials/#{referential.id}/edit">Editer</a></li>
                        <li><a rel="nofollow" data-method="put" href="/referentials/#{referential.id}/archive">Conserver</a></li>
                        <li class="delete-action"><a data-confirm="Etes-vous sûr(e) de vouloir effectuer cette action ?" rel="nofollow" data-method="delete" href="/referentials/#{referential.id}"><span class="fa fa-trash"></span>Supprimer</a></li>
                    </ul>
                </div>
            </td>
        </tr>
    </tbody>
</table>
      HTML
# <div class="select_toolbox noselect">
#     <ul>
#         <li class="st_action"><a data-path="/workbenches/1/referentials" data-confirm="Etes-vous sûr(e) de vouloir effectuer cette action ?" title="Supprimer" rel="nofollow" data-method="delete" href="#"><span class="fa fa-trash"></span></a></li>
#     </ul><span class="info-msg"><span>0</span> élément(s) sélectionné(s)</span>
# </div>

      html_str = helper.table_builder_2(
        referentials,
        { :name => 'name',
          :status => Proc.new {|w| w.archived? ? ("<div class='td-block'><span class='fa fa-archive'></span><span>Conservé</span></div>").html_safe : ("<div class='td-block'><span class='sb sb-lg sb-preparing'></span><span>En préparation</span></div>").html_safe},
          :status => Proc.new {|w| ("<div class='td-block'><span class='sb sb-lg sb-preparing'></span><span>En préparation</span></div>").html_safe},
          :organisation => Proc.new {|w| w.organisation.name},
          :validity_period => Proc.new {|w| w.validity_period.nil? ? '-' : t('validity_range', debut: l(w.try(:validity_period).try(:begin), format: :short), end: l(w.try(:validity_period).try(:end), format: :short))},
          :lines => Proc.new {|w| w.lines.count},
          :created_at => Proc.new {|w| l(w.created_at, format: :short)},
          :updated_at => Proc.new {|w| l(w.updated_at, format: :short)},
          :published_at => ''},
        selectable: true,
        links: [:show, :edit, :archive, :unarchive, :delete],
        cls: 'table has-filter has-search'
      )

      beautified_html = HtmlBeautifier.beautify(html_str, indent: '    ')

      expect(beautified_html).to eq(expected.chomp)
    end
  end
end


# Replace table builder on workspaces#show page
# Make the builder work without a `current_referential` so we can actually test it
# Make a way to define a column as non-sortable. By default, columns will be sortable. Unless sortable==false and no columns should be sortable.
#
#
# TODO:
# - Finish writing workbench test
# - Port some code over to the new table builder
# - Ask Jean-Paul if there's anything he wishes could be changed or improved about the existing table builder
# - Thing that Jean-Paul didn't like was the link generation
