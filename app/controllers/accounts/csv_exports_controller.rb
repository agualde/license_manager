module Accounts
  class CsvExportsController < ApplicationController
    before_action :set_account

    def show
      csv_data = generate_csv_data

      send_file csv_data,
        filename: csv_filename,
        type: "text/csv; charset=utf-8",
        disposition: "attachment"
    end

    private

    def generate_csv_data
      account_id = params[:account_id].to_i
      LicenseAssignments::Export::Csv.new(account_id).call
    end

    def csv_filename
      "account-csv-export-#{Date.current}.csv"
    end

    def set_account
      @account ||= Account.find(params[:account_id])
    end
  end
end
