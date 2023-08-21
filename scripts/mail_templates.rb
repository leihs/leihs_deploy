# Script which can be used to recreate mail templates.

class MigrationInventoryPool < ActiveRecord::Base
  self.table_name = 'inventory_pools'
  has_many :mail_templates
end

class MigrationMailTemplate < ActiveRecord::Base
  self.inheritance_column = nil
  self.table_name = 'mail_templates'
  belongs_to :inventory_pool
end

class MigrationLanguage < ActiveRecord::Base
  self.table_name = 'languages'
end

TEMPLATE_TEMPLATES = {
  reminder: {
    type: :user,
    body: <<-BODY.strip_heredoc
      Dear {{ user.name }},

      ** This is an automatically generated response **

      The following items are overdue or need to be inspected:

      {{ quantity }} item(s) due on {{ due_date | date: '%d/%m/%Y' }} at the inventory pool {{ inventory_pool.name }}
      {% for l in reservations %}
      * {{ l.quantity }} {{ l.model_name }} ({{ l.item_inventory_code }}), {{ l.start_date | date: '%d/%m/%Y' }} - {{ l.end_date | date: '%d/%m/%Y' }}
      {% endfor %}

      == Are any of the above items your personal computer?

      We kindly ask you to contact us as soon as possible. Your computer might need an update.

      == "Are any of the above borrowed items?

      Since we did not receive any request for renewal, we consequently demand the return of the items without further delay.

      By not returning these items, you are blocking other people's reservations. This is very unfair to the other clients and to the inventory manager, since you are causing a significant amount of trouble and annoyance.

      You might receive an admonishment and be subject to late fees as well as the restriction of borrowing privileges. In case of recurrence you might be barred from the reservation system for up to 6 months.

      Kind regards,

      {{ email_signature }}

      --
      {{ inventory_pool.name }}
      {{ inventory_pool.description }}
    BODY
  },

  deadline_soon_reminder: {
    type: :user,
    body: <<-BODY.strip_heredoc
      Dear {{ user.name }},

      ** This is an automatically generated response **

      The following items are due to be returned tomorrow or need to be inspected:

      {{ quantity }} item(s) due on {{ due_date | date: '%d/%m/%Y' }} at the inventory pool {{ inventory_pool.name }}
      {% for l in reservations %}
      * {{ l.quantity }} {{ l.model_name }} ({{ l.item_inventory_code }}), {{ l.start_date | date: '%d/%m/%Y' }} - {{ l.end_date | date: '%d/%m/%Y' }}
      {% endfor %}

      == Are any of the above items your personal computer?

      We kindly ask you to contact us as soon as possible. Your computer might need an update.

      == "Are any of the above borrowed items?

      We are just sending you this little reminder because someone else is already waiting for some of these items.

      In the interest of all our clients we ask you to observe the return dates.

      Kind regards,

      {{ email_signature }}

      --
      {{ inventory_pool.name }}
      {{ inventory_pool.description }}
    BODY
  },

  received: {
    type: :order,
    body: <<-BODY.strip_heredoc
      Dear leihs manager,

      ** This is an automatically generated response **

      An order for the following items listed below was received in an inventory pool you are responsible for.

      Inventory pool: {{ inventory_pool.name }}
      User: {{ user.name }}

      {% for l in reservations %}
      * {{ l.quantity }} {{ l.model_name }}, {{ l.start_date | date: '%d/%m/%Y' }} - {{ l.end_date | date: '%d/%m/%Y' }}
      {% endfor %}

      Purpose:
      {{ purpose }}

      Link: {{ order_url }}

      This order is still pending. Please log in to your leihs system and either approve or reject it.

      The user who placed this order has received a similar e-mail message informing them that the order first needs to be approved before it is valid.

      Kind regards,

      {{ email_signature }}

      --
      {{ inventory_pool.name }}
      {{ inventory_pool.description }}
    BODY
  },

  submitted: {
    type: :order,
    body: <<-BODY.strip_heredoc
      Dear {{ user.name }},

      ** This is an automatically generated response **

      Your order for the following items listed below was successfully submitted.

      Inventory pool: {{ inventory_pool.name }}

      {% for l in reservations %}
      * {{ l.quantity }} {{ l.model_name }}, {{ l.start_date | date: '%d/%m/%Y' }} - {{ l.end_date | date: '%d/%m/%Y' }}
      {% endfor %}

      Purpose:
      {{ purpose }}

      Unfortunately your order is still pending, but you will soon receive a confirmation of order by separate e-mail. You can view the status of your order through your leihs account.

      Kind regards,

      {{ email_signature }}

      --
      {{ inventory_pool.name }}
      {{ inventory_pool.description }}
    BODY
  },

  approved: {
    type: :order,
    body: <<-BODY.strip_heredoc
      Dear {{ user.name }},

      ** This is an automatically generated response **

      Your order for the following items has been confirmed by the inventory manager:

      Inventory pool: {{ inventory_pool.name }}

      {% for l in reservations %}
      * {{ l.quantity }} {{ l.model_name }}, {{ l.start_date | date: '%d/%m/%Y' }} - {{ l.end_date | date: '%d/%m/%Y' }}
      {% endfor %}

      {% if comment %}

      These are the comments of the inventory manager:

      {{ comment }}

      {% endif %}

      Kind regards,

      {{ email_signature }}

      --
      {{ inventory_pool.name }}
      {{ inventory_pool.description }}
    BODY
  },

  rejected: {
    type: :order,
    body: <<-BODY.strip_heredoc
      Dear {{ user.name }},

      ** This is an automatically generated response **

      Your order was rejected for the following reason:

      Inventory pool: {{ inventory_pool.name }}

      {% for l in reservations %}
      * {{ l.quantity }} {{ l.model_name }}, {{ l.start_date | date: '%d/%m/%Y' }} - {{ l.end_date | date: '%d/%m/%Y' }}
      {% endfor %}

      {{ comment }}

      Kind regards,

      {{ email_signature }}

      --
      {{ inventory_pool.name }}
      {{ inventory_pool.description }}
    BODY
  }
}

ActiveRecord::Base.transaction do

  TEMPLATE_TEMPLATES.each do |name, type:, body:|
    base_attrs = {
      name: name,
      type: type,
      format: :text
    }

    MigrationLanguage.all.each do |language|
      attrs = base_attrs.merge(language_locale: language.locale)

      # create missing admin mail template for a particular language
      unless MigrationMailTemplate.find_by(attrs.merge(is_template_template: true))
        MigrationMailTemplate.create!(attrs.merge(is_template_template: true, body: body))
      end

      MigrationInventoryPool.all.each do |inventory_pool|
        # skip if there is a already a mail template for an inventory pool
        unless MigrationMailTemplate.find_by(attrs.merge(inventory_pool_id: inventory_pool.id))
          # use admin mail template for the new inventory pool template
          tt = MigrationMailTemplate.find_by(attrs.merge(is_template_template: true))
          MigrationMailTemplate.create!(
            attrs.merge(inventory_pool_id: inventory_pool.id,
                        body: tt.body,
                        is_template_template: false)
          )
        end
      end
    end
  end

end
