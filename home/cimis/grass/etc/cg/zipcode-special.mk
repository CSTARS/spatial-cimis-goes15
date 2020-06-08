#! /usr/bin/make -f 

ifndef configure.mk
include configure.mk
endif

zipcode.mk:=1

parms:=Rs ETo K Rnl Tx Tn U2 Rso
#parms:=Rs ETo

.PHONY: info
info::
	@echo zipcode.mk - Create zipcode summaries for a particular day.  Add to SQLite db
	@echo ${rast}/Gc

.PHONY:zipcode

# These are backward calculations from what's done in original setup
# Wh/m^2 day -> MJ/m^2 day                                                                                                         

${rast}/Gc: ${rast}/Rso
	r.mapcalc "Gc=(Rso/0.0036)" &> /dev/null;
	@r.colors map=Rso rast=Rso@default_colors > /dev/null

${rast}/G: ${rast}/Rs
	r.mapcalc "G=(Rs/0.0036)" &> /dev/null;
	@r.colors map=Rs rast=Rso@default_colors > /dev/null

zipcode: $(etc)/zipcode.db
$(etc)/zipcode.csv: $(rast)/Tn $(rast)/Tx $(rast)/U2 $(rast)/ea $(rast)/Gc $(rast)/G $(rast)/K $(rast)/Rnl $(rast)/ETo
	g.region rast=zipcode_2012@zipcode;
	cg.zipcode.summary --noheader --nocount rast=Tn,Tx,U2,ea,Gc,G,K,Rnl,ETo > $@;\
	g.region -d;

$(etc)/zipcode.db: $(etc)/zipcode.csv
	echo -e "delete from zipcode_daily where d_date='$(MAPSET)';\n.mode csv\n.import $< zipcode_daily\n.quit" | ${sqlite}; \
	if [[ $$? == 0 ]] ; then touch $@; fi 


