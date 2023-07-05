class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    enable_extension :citext

    create_table :teams do |t|
      t.citext :name, index: {unique: true}
    end

    create_table :games do |t|
      t.references :opponent, foreign_key: {to_table: :teams}
      t.timestamp :occurs_at, index: {unique: true}
    end

    create_table :sections do |t|
      t.text :name, index: {unique: true}
      t.text :entrance
    end

    create_enum :ticket_status, ["pending", "available", "claimed"]

    create_table :tickets do |t|
      t.references :game, index: true, foreign_key: true
      t.references :section, index: true, foreign_key: true
      t.enum :status, enum_type: :ticket_status, default: "pending", null: false
      t.text :identifier, index: {unique: true}
      t.text :row
      t.text :seat
      t.timestamps
    end

    create_enum :ticket_source_status, ["pending", "processing", "completed", "rejected"]

    create_table :ticket_sources do |t|
      t.references :ticket, index: true, foreign_key: true
      t.text :message_id, null: false
      t.enum :status, enum_type: :ticket_source_status, default: "pending", null: false
      t.text :content, null: false
      t.timestamps
    end
  end
end
