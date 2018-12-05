pro simrun,obj,parameters
nom_f=parameters.out & if nom_f eq '' then nom_f='out'
nom=parameters.name
nom_f=nom_f+nom
nom_fichier0=nom_f+'_treeElement.xml'
openr,unit,nom_fichier0,/APPEND,/get_lun
sz=parameters.freq.n_freq
nobj=n_elements(parameters.objects)

for i=0,nobj-1 do if TAG_NAMES(*(parameters.objects[i]),/str) eq 'SOURCE' then begin
obj2=(*(parameters.objects[i]))
nom_f2=obj2.name+'_'+nom_f
nv=FIX((obj2.vmax-obj2.vmin)/obj2.vstep)+1
nlg=FIX((obj2.lgmax-obj2.lgmin)/obj2.lgstep)+1
nlat=FIX((obj2.latmax-obj2.latmin)/obj2.latstep)+1
n_src=nv*nlg*nlat

txtRegion=''
RgParam=''
Body0=''
txtField=''
for j=0,nobj-1 do if TAG_NAMES(*(parameters.objects[j]),/str) eq 'BODY' then begin
obj3=(*(parameters.objects[j]))
if txtRegion ne '' then txtRegion=txtRegion+string(13B)
if RgParam ne '' then RgParam=RgParam+string(13B)
if Body0 eq '' then begin
Body0=strtrim(obj3.name,2)
rad0=strtrim(string(obj3.radius),2)
endif
txtRegion=txtRegion+'<SimulatedRegion>'+strtrim(obj3.name,2)+'</SimulatedRegion>'
RgParam=RgParam+'<RegionParameters>'+string(13B)
RgParam=RgParam+'<SimulatedRegion>'+strtrim(obj3.name,2)+'</SimulatedRegion>'+string(13B)
RgParam=RgParam+'<Radius Units="km">'+strtrim(string(obj3.radius),2)+'</Radius>'+string(13B)
RgParam=RgParam+'<SubLongitude Units="degrees">'+strtrim(string(obj3.lg0),2)+'</SubLongitude>'+string(13B)
RgParam=RgParam+'<Period Units="s">'+strtrim(string(obj3.period*60),2)+'</Period>'+string(13B)
RgParam=RgParam+'<ObjectMass Units="kg">'+strtrim(string((2.*!pi/(obj3.orb_1r*60.))^2*(obj3.radius*1000.)^3/6.6738E-11),2)+'</ObjectMass>'+string(13B)
if obj3.motion eq 1b then begin
RgParam=RgParam+'<Property>'+string(13B)
RgParam=RgParam+'<PropertyQuantity>Positional</PropertyQuantity>'+string(13B)
RgParam=RgParam+'<PropertyLabel>Parent SemiMajorAxis SemiMinorAxis ApoapsisDeclination ApoapsisLongitude OrbitInclination InitialPhase</PropertyLabel>'
RgParam=RgParam+'<PropertyValue>'+strtrim((*obj3.parent).name,2)+' '
RgParam=RgParam+strtrim(string(obj3.semi_major_axis),2)+' '+strtrim(string(obj3.semi_minor_axis),2)+' '+strtrim(string(obj3.apoapsis_declination),2)+' '
RgParam=RgParam+strtrim(string(obj3.apoapsis_longitude),2)+' '+strtrim(string(obj3.orbit_inclination),2)+' '+strtrim(string(obj3.initial_phase),2)
RgParam=RgParam+'</PropertyValue>'+string(13B)
RgParam=RgParam+'<PropertyTableURL>http://sacred.latmos.ipsl.fr/ExPRES/tools/getBodyData?ResourceID='+rid+'&target='+strtrim(obj3.name,2)+'</PropertyTableURL>'+string(13B)
RgParam=RgParam+'</Property>'+string(13B)
RgParam=RgParam+'</RegionParameters>'
endif
for k=0,nobj-1 do if TAG_NAMES(*(parameters.objects[k]),/str) eq 'FEATURE' then begin
obj4=(*(parameters.objects[k]))
if (obj4.sat) then pr=(*(*obj4.parent).parent) else pr=(*obj4.parent)
if pr.name eq obj3.name then begin
n1=strsplit(obj4.name,'__',/EXTRACT) & n2=strsplit(n1[1],'_',/EXTRACT)
if n2[0] eq obj2.name then begin
if txtField ne '' then txtField=txtField+string(13B)
txtField=txtField+'<InputField>'+string(13B)
txtField=txtField+'<Name>'+n1+'</Name>'+string(13B)
txtField=txtField+'<SimulatedRegion>'+obj3.name+'</SimulatedRegion>'+string(13B)
txtField=txtField+'<FieldQuantity>Magnetic</FieldQuantity>'+string(13B)
txtField=txtField+'<InputModel>'+n1+'</InputModel>'+string(13B)
case n1 of 
'O6+Connerney CS':fld='http://dx.doi.org/10.1029/96JA02869'
'VIP4+Connerney CS' :fld='http://dx.doi.org/10.1029/97JA03726'
'VIPAL+Connerney CS' : fld='http://dx.doi.org/10.1029/2010JA016262'
'O6 Connerney CS':fld='http://dx.doi.org/10.1029/96JA02869'
'VIP4 Connerney CS' :fld='http://dx.doi.org/10.1029/97JA03726'
'VIPAL Connerney CS' : fld='http://dx.doi.org/10.1029/2010JA016262'
'SPV': fld='http://dx.doi.org/10.1029/JA095iA09p15257'
 'Z3': fld='http://dx.doi.org/10.1029/JA088iA11p08771'
 else: fld=''
end
txtField=txtField+'<ModelURL>'+fld+'</ModelURL>'+string(13B)
txtField=txtField+'</InputField>'
endif
endif
endif;FEATURE
endif;BODY

printf,unit,'<SimulationRun>'
text='<ResourceID>impex://LATMOS/SACRED/'+Body0+'_'+nom_f2+'</ResourceID>'
printf,unit,text
printf,unit,'<ResourceHeader>'
text='<ResourceName>SACRED_'+Body0+'_'+nom_f2+'</ResourceName>'
printf,unit,text
printf,unit,'<ReleaseDate>2012-02-21T00:00:00.000</ReleaseDate>'
printf,unit,'<Contact>'
printf,unit,'<PersonID>LATMOS</PersonID>'
printf,unit,'<Role>Publisher</Role>'
printf,unit,'</Contact>'
printf,unit,'<Contact>'
printf,unit,'<PersonID>Sebastien Hess</PersonID>'
printf,unit,'<Role>DataProducer</Role>'
printf,unit,'</Contact>'
printf,unit,'</ResourceHeader>'
printf,unit,'<AccessInformation>'
printf,unit,'<RepositoryID>impex://LATMOS/SACRED/NANCAY</RepositoryID>'
printf,unit,'<AccessURL>'
printf,unit,'<URL>http://sacred.latmos.ipsl.fr</URL>'
printf,unit,'</AccessURL>'
printf,unit,'</AccessInformation>'
printf,unit,'<Model><ModelID>LESIA/EXPRES</ModelID></Model>'
printf,unit,txtRegion
printf,unit,'<SimulationDomain>'
txt='<Name>'+Body0+'_Magnetosphere</Name>'
printf,unit,txt
printf,unit,'<CoordinateSystem>'
printf,unit,'<CoordinateRepresentation>Cartesian</CoordinateRepresentation>'
txt='<CoordinateSystemName>'+strmid(Body0,0,1)+'SO</CoordinateSystemName>'
printf,unit,txt
printf,unit,'</CoordinateSystem>'
printf,unit,'<SpatialDimension>3</SpatialDimension>'
printf,unit,'<VelocityDimension>3</VelocityDimension>'
printf,unit,'<FieldDimension>3</FieldDimension>'
printf,unit,'<Units>Rp</Units>'
txt='<UnitsConversion>'+rad0+' > km</UnitsConversion>
printf,unit,txt
printf,unit,'<BoxSize>50 50 50</BoxSize>'
printf,unit,'<ValidMin>-25 -25 -25</ValidMin>'
printf,unit,'<ValidMax>25 25 25</ValidMax>'
printf,unit,'<GridStructure>None</GridStructure>'
printf,unit,'<Symmetry>None</Symmetry>'
printf,unit,'</SimulationDomain>'
printf,unit,'<SimulationTime>'
printf,unit,'<Name>Time</Name>'
printf,unit,'<Duration>P1D</Duration>'
printf,unit,'<TimeStep>PT5M</TimeStep>'
printf,unit,'</SimulationTime>'
printf,unit,RgParam
printf,unit,txtField
printf,unit,'<InputPopulation>'
printf,unit,'<Name>Emitting electrons</Name>'
printf,unit,'<SimulatedRegion>Jupiter</SimulatedRegion>'
printf,unit,'<SimulatedRegion>Incident</SimulatedRegion>'
printf,unit,'<Mass Units="amu">0</Mass>'
printf,unit,'<Charge Units="e">-1</Charge>'
text='<Temperature Units="keV">'+strtrim(string(ener[0]),2)+' '+strtrim(string(ener[1]),2)+' '+strtrim(string(ener[2]),2)+'</Temperature>'
printf,unit,text
printf,unit,'<Distribution>Loss-Cone</Distribution>'
printf,unit,'</InputPopulation>'
printf,unit,'<InputParameter>'
printf,unit,'<SimulatedRegion>Jupiter</SimulatedRegion>'
printf,unit,'<ParameterQuantity>Current</ParameterQuantity>'
printf,unit,'<Property>'
printf,unit,'<Name>Type</Name>'
printf,unit,'<Value>Alfvenic</Value>'
printf,unit,'</Property>'
printf,unit,'<Property>'
printf,unit,'<Name>Origin</Name>'
text='<Value>'+strtrim(target,2)+'</Value>'
printf,unit,text
printf,unit,'</Property>'
printf,unit,'<Property>'
printf,unit,'<Name>LeadAngle</Name>'
printf,unit,'<PropertyQuantity>AzimuthAngle</PropertyQuantity>'
printf,unit,'<Value>0</Value>'
printf,unit,'</Property>'
printf,unit,'<Property>'
printf,unit,'<Name>Beam Width</Name>'
printf,unit,'<Value>1</Value>'
printf,unit,'</Property>'
printf,unit,'</InputParameter>'
printf,unit,'</SimulationRun>'
endif;SOURCE
close,unit & free_lun,unit

return
end

pro granule,target,mag_mod,e,day
  c=strtrim(strsplit(day,'-',/EXTRACT),2) 
  date=c[0]+'-'
  case c[1] of
   'Jan':  date=date+'01-'
   'Feb':  date=date+'02-'
   'Mar':  date=date+'03-'
   'Apr':  date=date+'04-'
   'May':  date=date+'05-'
   'Jun':  date=date+'06-'
   'Jul':  date=date+'07-'
   'Aug':  date=date+'08-'
   'Sep':  date=date+'09-'
   'Oct':  date=date+'10-'
   'Nov':  date=date+'11-'
   'Dec':  date=date+'12-'
  else: stop
  endcase
date=date+c[2]+'T'
openu,unit,'/home/seb/Bureau/SACRED/tree.xml',/APPEND,/get_lun
printf,unit,'<Granule>'
printf,unit,'<ResourceID>impex://LESIA/SACRED/J_JUICE_'+strtrim(target,2)+'_'+strtrim(mag_mod,2)+'_'+e+'_A_N/VOTABLE/'+day+'</ResourceID>'
printf,unit,'<ReleaseDate>2012-02-21T00:00:00.000</ReleaseDate>'
printf,unit,'<ParentID>impex://LESIA/SACRED/J_JUICE_'+strtrim(target,2)+'_'+strtrim(mag_mod,2)+'_'+e+'_A_N/VOTABLE</ParentID>'
printf,unit,'<StartDate>'+date+'00:00:00.000</StartDate>'
printf,unit,'<StopDate>'+date+'23:55:00.000</StopDate>'
printf,unit,'<Source>'
printf,unit,'<URL>/home/seb/Bureau/SACRED/res/J_JUICE_'+strtrim(target,2)+'_'+strtrim(mag_mod,2)+'_'+e+'_A_N_VOTABLE_'+day+'.vot</URL>'
printf,unit,'</Source>'
printf,unit,'</Granule>'
close,unit & free_lun,unit
return
end


pro numdat,target,mag_mod,ener
openu,unit,'/home/seb/Bureau/SACRED/tree.xml',/APPEND,/get_lun
printf,unit,'<NumericalData>'
e=strtrim((strsplit(string(ener[0]),'.',/EXTRACT))[0],2)
printf,unit,'<ResourceID>impex://LESIA/SACRED/J_JUICE_'+strtrim(target,2)+'_'+strtrim(mag_mod,2)+'_'+e+'_A_N/VOTABLE</ResourceID>'
printf,unit,'<ResourceHeader>'
printf,unit,'<ResourceName>SACRED_JUICE_'+strtrim(target,2)+'_'+strtrim(mag_mod,2)+'_'+e+'keV_NODENS_LC/VOTABLE</ResourceName>'
printf,unit,'<ReleaseDate>2012-05-05T00:00:00.000</ReleaseDate>'
printf,unit,'<Contact>'
printf,unit,'<PersonID>LATMOS</PersonID>'
printf,unit,'<Role>Publisher</Role>'
printf,unit,'</Contact>'
printf,unit,'<InformationURL>'
printf,unit,'<URL></URL>
printf,unit,'</InformationURL>'
printf,unit,'</ResourceHeader>'
printf,unit,'<AccessInformation>'
printf,unit,'<RepositoryID>impex://LESIA/SACRED/JUICE</RepositoryID>'
printf,unit,'<AccessURL>'
printf,unit,'<URL>http://typhon.obspm.fr/maser/sacred</URL>'
printf,unit,'</AccessURL>'
printf,unit,'<Format>VOTable</Format>'
printf,unit,'</AccessInformation>'
printf,unit,'<InstrumentID>impex://JUICE</InstrumentID>'
printf,unit,'<MeasurementType>MagneticField</MeasurementType>'
printf,unit,'<TemporalDescription>'
printf,unit,'<TimeSpan>'
printf,unit,'<StartDate>2029-11-01T00:00:00.000</StartDate>'
printf,unit,'<StopDate>2031-07-04T18:00:00.000</StopDate>'
printf,unit,'</TimeSpan>'
printf,unit,'<Cadence>PT300S</Cadence>'
printf,unit,'</TemporalDescription>'
printf,unit,'<SimulatedRegion>Jupiter</SimulatedRegion>'
printf,unit,'<InputResourceID>impex://LESIA/SACRED/J_JUICE_'+strtrim(target,2)+'_'+strtrim(mag_mod,2)+'_'+e+'_A_N</InputResourceID>'
printf,unit,'<Parameter>'
printf,unit,'<Name>Time</Name>'
printf,unit,'<Description>Time at which the measurement would have been made if it had been made by the spacecraft</Description>'
printf,unit,'<Support><SupportQuantity>Temporal</SupportQuantity></Support>'
printf,unit,'</Parameter>'
printf,unit,'<Parameter>'
printf,unit,'<Name>Northern_Visibilities</Name>'
printf,unit,'<Units></Units>'
printf,unit,'<ValidMin>0</ValidMin>'
printf,unit,'<ValidMax>1</ValidMax>'
printf,unit,'<Wave>'
printf,unit,'<WaveType>Electromagnetic</WaveType>'
printf,unit,'<WaveQuantity>Intensity</WaveQuantity>'
printf,unit,'</Wave>'
printf,unit,'</Parameter>'
printf,unit,'<Parameter>'
printf,unit,'<Name>Southern_Visibilities</Name>'
printf,unit,'<Units></Units>'
printf,unit,'<ValidMin>0</ValidMin>'
printf,unit,'<ValidMax>1</ValidMax>'
printf,unit,'<Wave>'
printf,unit,'<WaveType>Electromagnetic</WaveType>'
printf,unit,'<WaveQuantity>Intensity</WaveQuantity>'
printf,unit,'</Wave>'
printf,unit,'</Parameter>'
printf,unit,'</NumericalData>'
close,unit & free_lun,unit
return
end
