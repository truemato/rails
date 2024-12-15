class Stock < ApplicationRecord
    validates :name, presence: true, 
                        length: { maximum: 8 },
                                          format: { with: /\A[A-Za-z]+\z/ },
                                                            uniqueness: true
      validates :amount, presence: true,
                            numericality: { only_integer: true, 
                                                                              greater_than_or_equal_to: 0 }
end
