# AddField_management(in_table, field_name, field_type, {field_precision}, {field_scale}, {field_length}, {field_alias}, {field_is_nullable}, {field_is_required}, {field_domain})
#  Adds a new field to a table or the table of a feature class, feature layer,
# raster catalog, and/or rasters with attribute tables.

#      INPUTS:
#       in_table (Table View / Raster Layer / Raster Catalog Layer / Mosaic Layer):
#   The input table to which the specified field will be added. The field will be added to the existing input table and will not create a new output table.Fields can be added to feature classes of ArcSDE, file or personal geodatabases, coverages, shapefiles, raster catalogs, stand-alone tables, rasters with attribute tables, and/or layers.
#       field_name (String):
#   The name of the field that will be added to the Input Table.
#       field_type (String):
#   The field type used in the creation of the new field.

#   * TEXT—Names or other textual qualities.
#   * FLOAT—Numeric values with fractional values within a specific range.
#   * DOUBLE—Numeric values with fractional values within a specific range.
#   * SHORT—Numeric values without fractional values within a specific range; coded values.
#   * LONG—Numeric values without fractional values within a specific range.
#   * DATE—Date and/or Time.
#   * BLOB—Images or other multimedia.
#   * RASTER—Raster images.

#   * GUID—GUID values
#       field_precision {Long}:
#   Describes the number of digits that can be stored in the field. All digits are counted no matter what side of the decimal they are on.If the input table is a personal or file geodatabase the field precision value will be ignored.
#       field_scale {Long}:
#   Sets the number of decimal places stored in a field. This parameter is only used in Float and Double data field types.If the input table is a personal or file geodatabase the field scale value will be ignored.
#       field_length {Long}:
#   The length of the field being added. This sets the maximum number of allowable characters for each record of the field. This option is only applicable on fields of type text or blob.
#       field_alias {String}:
#   The alternate name given to the field name. This name is used to give more descriptive names to cryptic field names. The field alias parameter only applies to geodatabases and coverages.
#       field_is_nullable {Boolean}:
#   A geographic feature where there is no associated attribute information. These are different from zero or empty fields and are only supported for fields in a geodatabase.

#   * NON_NULLABLE—The field will not allow null values.

#   * NULLABLE—The field will allow null values. This is the default.
#       field_is_required {Boolean}:
#   Specifies whether the field being created is a required field for the table; only supported for fields in a geodatabase.

#   * NON_REQUIRED—The field is not a required field. This is the default.

#   * REQUIRED—The field is a required field. Required fields are permanent and can not be deleted.
#       field_domain {String}:
#   Used to constrain the values allowed in any particular attribute for a table, feature class, or subtype in a geodatabase. You must specify the name of an existing domain for it to be applied to the field.

arcpy.AddField_management("C:\\_Model\\Model.mdb\\mu_Geometry\\m_Station", "Source", "TEXT", "", "", "50", "", "NULLABLE", "NON_REQUIRED", "")

# Paste in ESRI Python Window - Geoprocessing / Python