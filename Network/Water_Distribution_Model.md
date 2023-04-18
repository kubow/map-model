[Water Resources Software (USGS.gov)](https://water.usgs.gov/software/lists/alphabetical)

[USEPA/WNTR: An EPANET compatible python package to simulate and analyze water distribution networks under disaster scenarios.](https://github.com/USEPA/WNTR)


## Water Distribution Network

- Junctions - represent points in the network where the pressure is measured
- Pipes - represent distribution paths
- Sources
	- Tanks
	- Reservoirs
- Valves
	- PRV (Pressure Reduction Valve) setting = pressure after the Valve ![[PRV.png]]
	- PSV (Pressure Sustain Valve) setting = pressure in front of Valve ![[PSV.png]]
	- PBV (Pressure Break Valve) setting = lower value of pressure ![[PBV.png]]
	- FCV (Flow Control Valve) setting = flow after the valve
	- TCV (Throttle Control Valve) setting = coefficient in formula $\Delta h=\xi v^{2}/2g$ ![[TCV.png]]
	- GPV (General Purpose Valve) contains relation curve:
		- Valve head loss
		- Valve operation schedule
- Pumps
	- [Pumps! That's what it's about (pumpfundamentals.com)](https://www.pumpfundamentals.com/)
	- [BAKALÁŘSKÁ PRÁCE (vut.cz)](https://www.vut.cz/www_base/zav_prace_soubor_verejne.php?file_id=75431)





## Best Practices

- Usually put PSV to inlet of Tank to control minimal pressure
- If to put two or more Valves in a row, always put a pipe between, otherwise causing instabilities
- For controlling outlet from pumps is used FCV (Setting = nomination l/s)



![[WD_Legend_Prutok.png]]

![[WD_Legend_Tlak.png]]