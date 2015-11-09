SalesCollection = require "../collections/SalesCollection"
ControlsView    = require "./ControlsView"
TableView       = require "./TableView"

class ChartView extends Marionette.ItemView
	template : require "../templates/chart.jade"
	drawn : false
	initialize : ({ @aggregated })->
		@listenTo @aggregated, "add", =>
			@data = _.reject @aggregated.toJSON(), (data) -> data.controls
			@range = _.chain @data
						.pluck "dollar"
						.map (data)->
							Math.ceil(data.substr 1)
						.value()
			return @drawChart() unless @chart
			@bars()

		@listenTo @aggregated, "remove", =>
			@data = _.reject @aggregated.toJSON(), (data) -> data.controls
			@range = _.chain @data
						.pluck "dollar"
						.map (data)->
							Math.ceil(data.substr 1)
						.value()
			return @drawChart() unless @chart
			@bars()
		
	drawChart : () ->
		@margin = { top : 30, right : 100, bottom: 30, left: 100 }
		@width  = 960 - @margin.left - @margin.right;
		@height = 500 - @margin.top - @margin.bottom


		@x = d3.scale.ordinal()
				.domain(@data.map (d) -> d.city)
				.rangeRoundBands [0, @width], .1

		@y = d3.scale.linear()
				.range([@height, 0])
				.domain [0, d3.max(@range)]

		@xAxis = d3.svg.axis()
					.scale @x
					.orient "bottom"

		@yAxis = d3.svg.axis()
					.scale @y
					.orient "left"
					.ticks 10

		@chart = d3.select(".view").append("svg")
					.attr "width", @width + @margin.left + @margin.right
					.attr "height", @height + @margin.top + @margin.bottom
					.append "g"
						.attr "transform", "translate(#{@margin.left}, #{@margin.top})"

		@yAxisSvg = @chart.append("g")
						.attr "class", "y axis"
						.call @yAxis
		
		@yAxisSvg.append("text")
					.attr "transform", "rotate(-90)"
					.attr "y", 6
					.attr "dy", ".71em"
					.style "text-anchor", "end"
					.text "Count"

		@xAxisSvg = @chart.append "g"
						.attr "class", "x axis"
						.attr("transform", "translate(0, "+@height+")")
						.call @xAxis

		@bars();
		# draw the bars

	bars: () ->
		bars = @chart.selectAll(".bar")
					.data(@data)

		@x.domain (@data.map (d) -> d.city).reverse()
		@y.domain [0, d3.max(@range)]

		@xAxisSvg.transition().call @xAxis
		@yAxisSvg.transition().call @yAxis

		bars.enter()
				.append "rect"
					.attr "class", "bar"
					.attr "y", (d) => @y 0
					.attr "height", @height - @y 0

		bars.transition()
				.attr "width", @x.rangeBand()
				.attr "x", (d) => @x d.city
				.attr "y", (d) => @y Math.ceil(d.dollar.substr 1)	
				.attr "height", (d) => @height - @y Math.ceil(d.dollar.substr 1)

		bars.exit().attr "y", @y 0
				.attr "height", @height - @y 0
				.style 'fill-opacity', 1e-6
				.remove();

		# set the domain

		# redraw the axis
		
		# select the bar
		
		# enter the bar
		
		# update it
		
		# remove if necessary

		



class PersonsView extends Marionette.LayoutView

	template: require "../templates/persons.jade"

	regions:
		controls: ".persons-controls"
		table:    ".persons-table"
		chart:    ".chart"

	initialize: ->
		controlsModel     = new Backbone.Model defaults: pause: false
		
		salesCollection = new SalesCollection controls: controlsModel
		
		@chartView    = new ChartView aggregated: salesCollection
		@tableView    = new TableView collection: salesCollection
		@controlsView = new ControlsView model: controlsModel


	onBeforeShow: ->
		@getRegion("chart").show @chartView
		@getRegion("controls").show @controlsView
		@getRegion("table").show @tableView

module.exports = PersonsView