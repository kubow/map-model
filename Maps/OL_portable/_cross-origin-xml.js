var map = new OpenLayers.Map({
    div: "map",
    layers: [
        new OpenLayers.Layer.OSM(),
        new OpenLayers.Layer.Vector("Vectors", {
            projection: new OpenLayers.Projection("EPSG:4326"),
            strategies: [new OpenLayers.Strategy.Fixed()],
            protocol: new OpenLayers.Protocol.Script({
                url: "http://query.yahooapis.com/v1/public/yql",
                params: {
                    q: "select * from xml where url='https://gist.githubusercontent.com/cly/bab1a4f982d43bcc53ff32d4708b8a77/raw/68f4f73aa30a7bdc4100395e8bf18bf81e1f6377/sample.gpx'"
                },
                format: new OpenLayers.Format.GPX(),
                parseFeatures: function(data) {
                    return this.format.read(data.results[0]);
                }
            }),
            eventListeners: {
                "featuresadded": function () {
                    this.map.zoomToExtent(this.getDataExtent());
                }
            }
        })
    ]
});
