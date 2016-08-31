var year = year = $("#year").val();

var diameter = 450; // Max size of the bubbles

var bubblef = d3.layout.pack()
    .sort(null)
    .size([diameter, diameter])
    .padding(1.5);

var bubblem = d3.layout.pack()
    .sort(null)
    .size([diameter, diameter])
    .padding(1.5);

// Bubbles femenino y masculino
var bubblesboth = [bubblef, bubblem];

// SVG femenino
var svgf = d3.select("body")
    .append("svg")
    .attr("width", diameter)
    .attr("height", diameter)
    .attr("class", "bubblef");

// SVG masculino
var svgm = d3.select("body")
    .append("svg")
    .attr("width", diameter)
    .attr("height", diameter)
    .attr("class", "bubblem");

// SVGs femenino y masculino
var svgs = [svgf, svgm];

// Colores femenino y masculino
var colores = ["#FFD6C1", "#E5EFC6"]

// Path a los datos de los años
var path = "/years/" + year + ".json";

d3.json(path, function(error, data){

    // Convert numerical values from strings to numbers
    // Data de top 10 femenina
    dataf = data.f.map(function(d){ d.value = +d.quantity; return d; });
    // Data de top 10 masculina
    datam = data.m.map(function(d){ d.value = +d.quantity; return d; });
    datas = [dataf, datam];
    var nodes, bubbles;

    // Iteramos por los dos géneros
    for (var i=0; i<datas.length; i++) {
        // Bubbles needs very specific format, convert data to this.
        nodes = bubblesboth[i].nodes({children:datas[i]}).filter(function(d) { return !d.children; });

        // Setup the chart
        bubbles = svgs[i].append("g")
            .attr("transform", "translate(0,0)")
            .selectAll(".bubble")
            .data(nodes)
            .enter();

        // Create the bubbles
        bubbles.append("circle")
            .attr("r", function(d){ console.log(d); return d.r; })
            .attr("cx", function(d){ return d.x; })
            .attr("cy", function(d){ return d.y; })
            .style("fill", function(d) { return colores[i]; });

        // Format the text for each bubble
        bubbles.append("text")
            .attr("x", function(d){ return d.x; })
            .attr("y", function(d){ return d.y + 5; })
            .attr("text-anchor", "middle")
            .text(function(d){ return processNameForBubble(d.name); })
            .style({
                "fill":"#646363", 
                "font-family":"Helvetica Neue, Helvetica, Arial, san-serif",
                "font-size": "14px"
            }); 
    }

    
});

function toTitleCase(str)
{
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

function processNameForBubble(name) {
    var processedName = window.DataProcessor.prototype._processName(name);

    processedName = processedName.replace("_", " ");
    
    return toTitleCase(processedName);
}