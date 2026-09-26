private void _CreateFakeLayer()
{
    bool isAdded = false;
    if (_mapInterventions.Layers.Count > 0)
    {
        ILayer layer = _mapInterventions.Layers.ToList().Find(item => item.Name.Equals("Interventions"));
        if (layer != null)
        {
            isAdded = true;
        }
    }
    if (!isAdded)
    {
        IFeatureClass featureClass = _gisModule.FeatureClassList.CreateNew();
        featureClass.CoordinateSystem = _gisModule.DefaultCoordinateSystem;
        featureClass.Name = "Interventions";
        featureClass.GeometryType = GeometryType.LineString;
        featureClass.Id = Guid.NewGuid();

        IFeatureClassAttribute attribute = featureClass.AttributeList.CreateNew();
        attribute.Name = "InterventionType";
        attribute.Type = typeof(string);
        featureClass.AttributeList.Add(attribute);

        foreach (string temp in _interventColorDic.Keys)
        {
            IFeature feature = featureClass.CreateNew();
            ////feature.Geometry = new Geometry(projectPoint.ToWKT());
            feature["InterventionType"] = temp;
        }

        IFeatureLayer featureLayer = new DHI.Solutions.GISManager.UI.FeatureLayer(featureClass, _shell);
        featureLayer.Name = "Interventions";
        featureLayer.IsVisible = false;
        featureLayer.ShowInLegend = true;
        featureLayer.StyleType = StyleType.UniqueValues;

        // Remove default unique value styles
        UniqueValuesLayerStyle uniqueValuesLayerStyle = featureLayer.LayerStyle as UniqueValuesLayerStyle;
        List<IStyle> uniqueStyleList = new List<IStyle>(uniqueValuesLayerStyle);
        foreach (IStyle style in uniqueStyleList)
        {
            uniqueValuesLayerStyle.Remove(style);
        }
        uniqueValuesLayerStyle.Attribute = "InterventionType";
        foreach (string temp in _interventColorDic.Keys)
        {
            IStyle style = new DHI.Solutions.GISManager.UI.LineStyle();
            style.Color = _interventColorDic[temp];
            uniqueValuesLayerStyle.Add(temp, style);
        }
        _mapInterventions.Layers.Add(featureLayer);
    }
}
