Deface::Override.new(
  virtual_path: 'spree/admin/products/_form',
  name: 'product_return_days_field',
  insert_after: "[data-hook='admin_product_form_returnable']",
  text: "
        <div data-hook='admin_product_form_return_days' class='alpha two columns'>
          <%= f.field_container :return_days, class: ['form-group'] do %>
            <%= f.label :return_days, Spree.t(:return_days, scope: [:model, :backend, :product]) %>
            <%= f.text_field :return_days, class: 'form-control' %>
            <p><b><small>(0 - returnable days)</small></b></p>
            <%= f.error_message_on :return_days %>
          <% end %>
        </div>
        ",
  sequence: { after: 'product_returnable_checkbox_button' }
)
