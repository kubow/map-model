# -- coding: cp1252
import numpy as np
import re
try:
    import mpl_toolkits.basemap.pyproj as pyproj # Import the pyproj module
except ImportError:
    print '.. ' #do not have pyproj library...'
    # can do things like pyproj.Proj(krovak_proj)

# Define a projection with Proj4 notation, S-JTSK Krovak
# krovak_proj="+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.2881397222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m +towgs84=570.83789,85.682641,462.84673,4.9984501,1.5867074,5.2611106,3.5610256"
# krovak_srt = 'PROJCS["SJTSK_Krovak_East_North",GEOGCS["GCS_S_JTSK",DATUM["D_S_JTSK",SPHEROID["Bessel_1841",6377397.155,299.1528128]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Krovak"],PARAMETER["False_Easting",0], PARAMETER["False_Northing",0],PARAMETER["Pseudo_Standard_Parallel_1",78.5],PARAMETER["Scale_Factor",0.9999],PARAMETER["Azimuth",30.2881397222222],PARAMETER["Longitude_Of_Center",24.83333333333333],PARAMETER["Latitude_Of_Center",49.5], PARAMETER["X_Scale",-1], PARAMETER["Y_Scale",1],PARAMETER["XY_Plane_Rotation",90],UNIT["Meter",1]]'

class PolynomalTransferKrovakWGS:
    def __init__(self, mode="Krovak"):
        self.str_format = "{0} / {1}"
        self.ref_fi = 50
        self.ref_lambda = 15
        self.ref_y = 1058000.000000000
        self.ref_x = 703000.000000000
        degree_sign= u'\N{DEGREE SIGN}'
        if mode == "Krovak":
            self.pol_x1 = 1.325132993E-03
            self.pol_x2 = -8.916429099E-06
            self.pol_x3 = -1.156917384E-06
            self.pol_x4 = -2.298750250E-14
            self.pol_x5 = 2.087176527E-13
            self.pol_x6 = -8.219794748E-13
            self.pol_x7 = 2.191874854E-20
            self.pol_x8 = 5.305545189E-21
            self.pol_x9 = 1.760134043E-19
            self.pol_x10 = 6.270628603E-21
            self.pol_y1 = -1.019442857E-04
            self.pol_y2 = 1.794902692E-06
            self.pol_y3 = -1.383338939E-05
            self.pol_y4 = -3.294257309E-13
            self.pol_y5 = 2.506009659E-12
            self.pol_y6 = 3.291143794E-13
            self.pol_y7 = 4.567560092E-20
            self.pol_y8 = -4.843979237E-19
            self.pol_y9 = -1.182561606E-19
            self.pol_y10 = 1.641107774E-19
        elif 'wgs' in mode:
            self.pol_x1 = 1.180672981E+01
            self.pol_x2 = -1.431119075E+04
            self.pol_x3 = -7.109369068E+04
            self.pol_x4 = 4.527213114E-02
            self.pol_x5 = 1.469297520E+03
            self.pol_x6 = -6.216573827E+01
            self.pol_x7 = 1.746024222E+00
            self.pol_x8 = 1.482366057E+00
            self.pol_x9 = -1.646574057E+00
            self.pol_x10 = 1.930950004E+00
            self.pol_y1 = 1.471808238E+02
            self.pol_y2 = -1.102950611E+05
            self.pol_y3 = 9.224512054E+03
            self.pol_y4 = -1.335425822E+01
            self.pol_y5 = -1.928902631E+02
            self.pol_y6 = -4.735502716E+02
            self.pol_y7 = -4.564660084E+00
            self.pol_y8 = -4.355296392E+00
            self.pol_y9 = 8.911019558E+00
            self.pol_y10 = 3.614170182E-01
        else:
            print '...not specified original coordinate system'

def pow(x, y):
    """Raise x to the power y, where y must be a nonnegative integer."""
    result = float(1)
    for _ in range(y):   # using _ to indicate throwaway iteration variable
        result *= float(x)
    return result

def to_degree_format(number):
    """submit decimal number format, return triplet of decimal numbers"""
    number_hrs = int(number)
    number_min = int(float(number-number_hrs)*60)
    number_sec = float(float(number-number_hrs)*60-number_min)*60
    return number_hrs, number_min, round(number_sec, 4)
    
def to_decimal_format(dec_number):
    """submit degree number format, return decimal number"""
    if p.degree_sign in dec_number:
        number_hrs = dec_number.split(p.degree_sign)[0]
        rest = dec_number.split(p.degree_sign)[0]
        if '"' in rest:
            number_hrs = rest.split('"')[0]

    
def easy_to_krovak(coord_x, coord_y):
    if p.degree_sign in coord_x:
        coord_x = to_decimal_format(coord_x)
    if p.degree_sign in coord_y:
        coord_y = to_decimal_format(coord_y)
    t_lambda
    t_fi
 

def easy_to_wgs84(coord_x, coord_y):
    if coord_x < 0:
        coord_x = -1 * coord_x 
    if coord_y < 0:
        coord_y = -1 * coord_y 
    delta_lambda = float(coord_y - p.ref_y)
    delta_fi = float(coord_x - p.ref_x)
    print "lambda ({0}) / fi ({1})".format(delta_lambda, delta_fi)
    pol_x2 = p.pol_x2 * delta_lambda
    pol_x3 = p.pol_x3 * delta_fi
    pol_x4 = p.pol_x4 * pow(delta_lambda, 2)
    pol_x5 = p.pol_x5 * delta_lambda * delta_fi
    pol_x6 = p.pol_x6 * pow(delta_fi, 2)
    pol_x7 = p.pol_x7 * pow(delta_lambda, 3)
    pol_x8 = p.pol_x8 * delta_fi * pow(delta_lambda, 2)
    pol_x9 = p.pol_x9 * delta_lambda * pow(delta_fi, 2)
    pol_x10 = p.pol_x10 * pow(delta_fi, 3)
    
    pol_y2 = p.pol_y2 * delta_lambda
    pol_y3 = p.pol_y3 * delta_fi
    pol_y4 = p.pol_y4 * pow(delta_lambda, 2)
    pol_y5 = p.pol_y5 * delta_lambda * delta_fi
    pol_y6 = p.pol_y6 * pow(delta_fi, 2)
    pol_y7 = p.pol_y7 * pow(delta_lambda, 3)
    pol_y8 = p.pol_y8 * delta_fi * pow(delta_lambda, 2)
    pol_y9 = p.pol_y9 * delta_lambda * pow(delta_fi, 2)
    pol_y10 = p.pol_y10 * pow(delta_fi, 3)
    
    x = p.ref_fi + p.pol_x1 + pol_x2 + pol_x3 + pol_x4 + pol_x5 + pol_x6 + pol_x7 + pol_x8 + pol_x9 + pol_x10
    y = p.ref_lambda + p.pol_y1 + pol_y2 + pol_y3 + pol_y4 + pol_y5 + pol_y6 + pol_y7 + pol_y8 + pol_y9 + pol_y10
    
    x_d, x_m, x_s = to_degree_format(x)
    y_d, y_m, y_s = to_degree_format(y)
    print len(to_degree_format(x))
    print len(to_degree_format(y))
    
    minute_string = "{0}" + p.degree_sign + """{1}"{2}'"""
    x_minute_string = minute_string.format(to_degree_format(x))
    y_minute_string = minute_string.format(to_degree_format(y))
    # x_minute_string = minute_string.format(x_d, int(x_m), round(x_s,4))
    # y_minute_string = minute_string.format(y_d, int(y_m), round(y_s,4))
    print x_minute_string + " / " + y_minute_string
    return x, y
    
    
if __name__ == '__main__':
    p = PolynomalTransferKrovakWGS(mode="Krovak")

    coord_list = ((-753658.4683, -1029816.237),
                   (-753435.3257, -1029407.8921),
                    (-753498.3314, -1030133.0775))
    for coord_x, coord_y in coord_list:
        print "="*50
        krovak_x, krovak_y = easy_to_wgs84(coord_x, coord_y)
        print p.str_format.format(krovak_x, krovak_y)
    # print "="*50

    # x, y = (-753658.4683, -1029816.237)
    # krovak_x, krovak_y = easy_to_wgs84(x, y)
    # print p.str_format.format(krovak_x, krovak_y)
        
    
    
    
    
