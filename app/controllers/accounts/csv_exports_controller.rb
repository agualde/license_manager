module Accounts
  class CsvExportsController < ApplicationController
    before_action :set_account

    def show
      file_path = LicenseAssignments::Export::Csv.new(account_id).call

      send_file file_path,
        filename: "accounts-#{Date.current}.csv",
        type: "text/csv; charset=utf-8",
        disposition: "attachment",
        x_sendfile: false
    end

    private

    def account_id
      @id ||= @account.id
    end

    def set_account
      @account ||= Account.find(params[:account_id])
    end
  end
end
