class TrelloUtils
  
  def self.cards_update_actions
    @@trello_cards_update_actions ||= [
      "addMemberToCard",
      "convertToCardFromCheckItem",
      "copyCard",
      "createCard",
      "moveCardToBoard",
      "updateCard:closed",
      "updateList:closed"
    ]
    @@trello_cards_update_actions
  end

  def self.cards_update_actions_to_s
    @@trello_cards_update_actions_to_s ||= TrelloUtils.cards_update_actions.join(',')
    @@trello_cards_update_actions_to_s
  end

  def self.cards_delete_actions
    @@trello_cards_delete_actions ||= [
      "deleteCard",
      "moveCardFromBoard",
      "removeMemberFromCard",
      "updateCard:closed",
      "updateList:closed"
    ]
    @@trello_cards_delete_actions
  end

  def self.cards_delete_actions_to_s
    @@trello_cards_delete_actions_to_s ||= TrelloUtils.cards_delete_actions.join(',')
    @@trello_cards_delete_actions_to_s
  end

  def self.updated_board_actions
    @@updated_board_actions ||= [
      "addMemberToCard",
      "convertToCardFromCheckItem",
      "copyCard",
      "createCard",
      "moveCardToBoard",
      "updateCard:closed",
      "updateList:closed"
    ]
    @@updated_board_actions
  end

  def self.updated_board_actions_to_s
    @@updated_board_actions_to_s ||= TrelloUtils.updated_board_actions.join(',')
    @@updated_board_actions_to_s
  end

  def self.get_cards_from_actions(actions, client)
    cards = actions.map do |action|
      card_id = action.data["card"]["id"]
      begin
        if action.type == 'deleteCard'
          deleted_card = OpenStruct.new(action.data["card"])
          deleted_card.list_id = action.data["list"]["id"] if action.data["list"].present?
          deleted_card.board_id = action.data["board"]["id"]
          deleted_card.type = :deleted_card
          deleted_card
        else
          Trello::Card.from_response client.get("/cards/#{card_id}")
        end
      rescue
        puts action.to_json
        raise
      end
    end
    cards
  end

end