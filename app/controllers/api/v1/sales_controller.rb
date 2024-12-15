module Api
 module V1
   class SalesController < ApplicationController
     def index
       # salesテーブルの最新レコードのtotalを小数点第2位まで表示
       latest_sale = Sale.order(id: :desc).first
       total = latest_sale ? latest_sale.total.round(2) : 0.00
       render json: { sales: total.to_f }
     end

     def create
       ActiveRecord::Base.transaction do
         # 商品の存在チェック
         stock = Stock.find_by!(name: sale_params[:name])
         puts "商品が見つかりました：#{stock.name}"

         # 数量の計算と検証
         amount = calculate_amount(sale_params[:amount])
         puts "数量の検証が通過しました：#{amount}"

         price = sale_params[:price]
         puts "価格：#{price}"

         # 在庫チェック
         if stock.amount < amount
           puts "在庫不足エラー: 必要量#{amount}に対し在庫#{stock.amount}"
           return render_error
         end

         # 在庫を減らす
         stock.amount -= amount
         stock.save!
         puts "在庫を更新しました：残り#{stock.amount}"

         # 売上の更新（priceがある場合のみ）
         if price
           puts "売上の更新を開始します"
           update_sales_total(amount, price.to_f)
           puts "売上を更新しました"
         else
           puts "価格の指定がないため、売上は更新しません"
         end

         # レスポンス
         response.headers['Location'] = api_v1_sales_url(sale_params[:name])
         render json: { name: sale_params[:name], amount: amount }
       end

     rescue ActiveRecord::RecordNotFound
       puts "商品が見つかりませんでした"
       render_error
     rescue => e
       puts "予期せぬエラー: #{e.message}"
       render_error
     end

     private

     def sale_params
       {
         name: params[:name] || params.dig(:sale, :name),
         amount: params[:amount],  # nilなら後でデフォルト値1を使用
         price: params[:price]     # nilならスキップ
       }
     end

     def calculate_amount(raw_amount)
       if raw_amount.nil?
         puts "数量の指定なし、デフォルト値1を使用"
         return 1
       end

       amount = raw_amount.to_i
       if amount <= 0
         puts "数量が0以下のエラー: #{amount}"
         raise ArgumentError
       end
       
       if raw_amount.to_f != amount.to_f
         puts "小数点を含む数量エラー: #{raw_amount}"
         raise ArgumentError
       end

       amount
     rescue ArgumentError
       puts "数量の検証でエラー"
       render_error
     end

     def update_sales_total(amount, price)
       sale = Sale.new
       latest_sale = Sale.order(id: :desc).first
       current_total = latest_sale ? latest_sale.total : 0
       new_total = current_total + (price * amount)
       puts "売上計算: 現在の合計#{current_total} + (#{price} * #{amount}) = #{new_total}"
       sale.total = new_total
       sale.save!
     end

     def render_error
       render json: { message: ERROR }, status: :unprocessable_entity
     end
   end
 end
end
