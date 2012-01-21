<?
date_default_timezone_set('America/Chicago');
$since = date("H:i Y-m-d", filemtime("day"));
?>
<!DOCTYPE HTML>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Hatchery Touches</title>
		
		
		<!-- 1. Add these JavaScript inclusions in the head of your page -->
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
		<script type="text/javascript" src="js/highcharts.js"></script>
		
		<!-- 1a) Optional: add a theme file -->
		<!--
			<script type="text/javascript" src="../js/themes/gray.js"></script>
		-->
		
		<!-- 1b) Optional: the exporting module -->
		<script type="text/javascript" src="js/modules/exporting.js"></script>
		
		
		<!-- 2. Add the JavaScript to initialize the chart on document ready -->
		<script type="text/javascript">
			var chart;
			$(document).ready(function() {
				chart = new Highcharts.Chart({
					chart: {
						renderTo: 'container',
						zoomType: 'x',
						spacingRight: 20
					},
				    title: {
					    text: 'Hatchery Touches as of <?=$since?>'
					},
				    subtitle: {
						text: document.ontouchstart === undefined ?
							'Click and drag in the plot area to zoom in' :
							'Drag your finger over the plot to zoom in'
					},
					xAxis: {
						type: 'datetime',
            maxZoom: 3600000, 
            labels: {
                      formatter: function() {
		      //return Highcharts.dateFormat('%H:%M<br />%a %d %b', this.value - (6 * 3600 * 1000));
		      return Highcharts.dateFormat('%d %b', this.value );
                      }
                    },
						title: {
							text: 'date'
						}
					},
					yAxis: {
						title: {
							text: 'touches'
						},
            min: 0,
            //max: 2,
						startOnTick: false,
						showFirstLabel: false
					},
					tooltip: {
            shared: false,
            formatter: function(){ return Highcharts.dateFormat(this.y+' - %a %d %b %Y', this.x); }

					},
					legend: {
						enabled: false
					},
					plotOptions: {
						area: {
							fillColor: {
								linearGradient: [0, 0, 0, 300],
								stops: [
									[0, Highcharts.getOptions().colors[0]],
									[1, 'rgba(2,0,0,0)']
								]
							},
							lineWidth: 1,
							marker: {
								enabled: true,
								states: {
									hover: {
										enabled: true,
										radius: 5
									}
								}
							},
							shadow: false,
							states: {
								hover: {
									lineWidth: 1						
								}
							}
						}
					},
				
					series: [{
						type: 'column',
						//type: 'bar',
						name: 'hatchery touches',
						//pointInterval: 1000,
						//pointStart: Date.UTC(2011, 11, 14),
            data: [
<?php
$f = file_get_contents('out');
$total= count(explode("\n", $f));
$f = file_get_contents('days');
$overdays = substr_count($f,"\n");
echo $f;
?>	    
 
  ]
					}]
				});
				
				
			});
				
		</script>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
	    <script type="text/javascript">
    
      // Load the Visualization API and the piechart package.
      google.load('visualization', '1.0', {'packages':['corechart']});
      
      // Set a callback to run when the Google Visualization API is loaded.
      google.setOnLoadCallback(drawDOWChart);
      google.setOnLoadCallback(drawHourChart);
      
      // Callback that creates and populates a data table, 
      // instantiates the pie chart, passes in the data and
      // draws it.
      function drawDOWChart() {

      // Create the data table.
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'Day of Week');
      data.addColumn('number', 'Touches');
      data.addRows([
	<? echo file_get_contents('day'); ?>
      ]);

      // Set chart options
      var options = {'title':'Touches Throughout the Week',
                     'width':500,
                     'height':500};

      // Instantiate and draw our chart, passing in some options.
      var chart = new google.visualization.BarChart(document.getElementById('chart_dow_div'));
      chart.draw(data, options);
      var pchart = new google.visualization.PieChart(document.getElementById('chart_dowp_div'));
      pchart.draw(data, options);
      }


      // Callback that creates and populates a data table, 
      // instantiates the pie chart, passes in the data and
      // draws it.
      function drawHourChart() {

      // Create the data table.
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'Hour of Day');
      data.addColumn('number', 'Touches');
      data.addRows([
	<? echo file_get_contents('hour'); ?>
	]);

      // Set chart options
      var options = {'title':'Touches by Hour',
                     'width':600,
                     'height':600};

      // Instantiate and draw our chart, passing in some options.
      var chart = new google.visualization.BarChart(document.getElementById('chart_hour_div'));
      chart.draw(data, options);
      var pchart = new google.visualization.PieChart(document.getElementById('chart_hourp_div'));
      pchart.draw(data, options);
    }
    </script>
	
	</head>
	<body>
		
		<!-- 3. Add the container -->
		<div id="container" style="width: 900px; height: 400px; margin: 0 auto"></div>
		<br />
		<br />
		<p>Total number of touches is <?=$total?> over <?=$overdays?> days.</p>
		<p>
			This is a graph of events from the <a href='http://www.popupartloop.com/active.php?id=123'>Hatchery</a> art installation at 210 N. Wells Chicago, IL. Every time someone interacts with the scultpure, the date and time of the interaction is logged and later displayed on these graphs.
		</p>		
		<hr/>
    <div id="chart_dow_div" style="float:left;"></div>
    <div id="chart_dowp_div"></div>
		<hr/>
    <div id="chart_hour_div" style="float:left;"></div>
    <div id="chart_hourp_div"></div>
	</body>
</html>
