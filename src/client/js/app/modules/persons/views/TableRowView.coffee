class TableRowView extends Marionette.ItemView

	tagName:     "tr"
	modelEvents: change: "render"
	template:    require "../templates/tablerow.jade"

	events:
		"click button": "buttonClicked"

	buttonClicked: ->
		@model.destroy()

	render: ->
		console.log @model
		@model.get "hide"
		if @model.get "hide"
			@$el.css "display", "none"
		else
			@$el.css "display", "table-row"
		super

module.exports = TableRowView