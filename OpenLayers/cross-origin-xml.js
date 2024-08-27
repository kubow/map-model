var map = new OpenLayers.Map({
    div: "map",
    layers: [
        new OpenLayers.Layer.OSM(),
        new OpenLayers.Layer.Vector("Vectors", {
            projection: new OpenLayers.Projection("EPSG:4326"),
            strategies: [new OpenLayers.Strategy.Fixed()],
            protocol: new OpenLayers.Layer.GML("GML", "pokus.xml"),
            eventListeners: {
                "featuresadded": function () {
                    this.map.zoomToExtent(this.getDataExtent());
                }
            }
        })
    ]
});
