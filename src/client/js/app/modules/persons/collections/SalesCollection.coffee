class SalesModel extends Backbone.Model

class SalesCollection extends Backbone.Collection

	url:        "persons"
	model: 	    SalesModel
	comparator: (sales) -> -sales.get "timestamp"

	initialize: ({ @controls }) ->
		@ioBind "create", @serverCreate

	serverCreate: (sales) =>
		@add sales unless @controls.get "pause"

		@pop() if @length > 5

module.exports = SalesCollection