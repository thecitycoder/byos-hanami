# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Items
        # The create action.
        class Create < Action
          include Deps[
            repository: "repositories.playlist_item",
            playlist_repository: "repositories.playlist",
            show_view: "views.playlists.items.show"
          ]

          params do
            required(:playlist_id).filled :integer
            required(:playlist_item).hash { required(:screen_id).filled :integer }
          end

           def handle request, response
             parameters = request.params
             playlist = playlist_repository.find parameters[:playlist_id]

             if parameters.valid?
               item = create(playlist, parameters)
               response.redirect routes.path(:playlist, id: playlist.id), success: "Item added successfully"
             else
               halt :unprocessable_content
             end
           end

          private

          def create playlist, parameters
            playlist_id = playlist.id
            item = repository.create_with_position playlist_id:, **parameters[:playlist_item]

            playlist_repository.update_current_item playlist_id, item
            item
          end
        end
      end
    end
  end
end
