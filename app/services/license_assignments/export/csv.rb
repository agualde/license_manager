module LicenseAssignments
  module Export
    class Csv
      def initialize(account_id, file_path = nil)
        @file_path = file_path || default_file_path
        @account_id = account_id
      end

      def call
        generate_csv

        @file_path
      end

      private

      def default_file_path
        timestamp = Time.current.strftime("%Y%m%d%H%M%S")
        Rails.root.join("tmp", "account_export_#{timestamp}.csv")
      end

      def account
        @accounts ||= Account.find(@account_id)
      end

      def generate_csv
        ::CSV.open(@file_path, "wb") do |csv|
          csv << headers
          begin
            account.users.each do |user|
              user.products.each do |product|
                csv << build_csv_row(user, product)
              end
            end
          end
        end
      end

      def build_csv_row(user, product)
        [
          user.name,
          product.name
        ]
      end

      def headers
        [ "User name", "License" ]
      end
    end
  end
end
