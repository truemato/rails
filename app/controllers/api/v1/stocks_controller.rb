module Api
  module V1
    class StocksController < ApplicationController
      
      def index
        stocks = Stock.where('amount > 0').order(:name)
        render json: stocks.pluck(:name, :amount).to_h
      end
      def show
        stock = Stock.find_by!(name: params[:id])
        render json: { stock.name => stock.amount }
      rescue ActiveRecord::RecordNotFound
        render json: { stock.name => 0 }
      end
      def create
        if !amount_params(stock_params[:amount])
          render json: { message: 'ERROR' }, status: :unprocessable_entity
          return
        end
        stock = Stock.find_or_initialize_by(name: stock_params[:name])
        amount = (stock_params[:amount] || 1).to_i
        stock.amount += amount
        if stock.save
          response.headers['Location'] = api_v1_stock_url(stock.name)
          render json: { name: stock.name, amount: amount }
        else
          render json: { message: 'ERROR' }, status: :unprocessable_entity
        end
      end
      def destroy
        Stock.delete_all
        Sale.delete_all
        head :no_content
      end
      private
      def stock_params
        params.require(:stock).permit(:name, :amount)
      end
      def amount_params(value)
        return true if value.nil?
        return false if value.to_f != value.to_i
        true
      end
    end
  end
end
