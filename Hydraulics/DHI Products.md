- [Browse Software Products](https://www.mikepoweredbydhi.com/products)
	- [[#MikeIPO]] (?deprecated)
- [Tools & Add-Ons](https://www.mikepoweredbydhi.com/download/mike-by-dhi-tools)
- 

[DHI Czech Republic](https://worldwide.dhigroup.com/cz)

[DHI Developers (Internal)](https://dhi-developer-documentation.azurewebsites.net/)

## MikeIPO

We are now able to work with **JTSK East North in Mike IPO precisely**.  

To teach Mike IPO the precise version of JTSK East North you need after each Database restore execute following sql on workspace ‚public‘.  

If you want to be able to export a shapefile from MC that is in SJTSK_Krovak_East_North, the you need to add the definition below to the file [ESRIProjections.txt](file:///c:/Program%20Files%20(x86)/DHI/2016/MIKE%20INFO%202/ESRIProjections.txt), otherwise you will get error (feature class is defined in coordinate system with no mapping):  

```sql
_102067,PROJCS["S-JTSK_Krovak_East_North",GEOGCS["GCS_S_JTSK",DATUM["D_S_JTSK",SPHEROID["Bessel_1841",6377397.155,299.1528128]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Krovak"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Pseudo_Standard_Parallel_1",78.5],PARAMETER["Scale_Factor",0.9999],PARAMETER["Azimuth",30.28813975277778],PARAMETER["Longitude_Of_Center",24.83333333333333],PARAMETER["Latitude_Of_Center",49.5],PARAMETER["X_Scale",-1],PARAMETER["Y_Scale",1],PARAMETER["XY_Plane_Rotation",90],UNIT["Meter",1]]_ 
```


