include	<error.h>
include	<smw.h>


# SMW_OPEN -- Open SMW structure.
# The basic MWCS pointer and a template SMW pointer or spectrum is input
# and the SMW pointer is returned in its place.

procedure smw_open (mw, smw1, im)

pointer	mw		#U MWCS pointer input and SMW pointer output
pointer	smw1		#I Template SMW pointer
pointer	im		#I Spectrum pointer

int	i, nspec, nmw, format, strdic()
pointer	sp, sys, smw, mw_sctran(), mw_newcopy()
errchk	smw_daxis, smw_sax, mw_sctran, mw_gwattrs

begin
#call eprintf ("smw_open (%d, %d, %d)\n")
#call pargi (mw)
#call pargi (smw1)
#call pargi (im)
	call smark (sp)
	call salloc (sys, SZ_FNAME, TY_CHAR)

	iferr (call mw_gwattrs (mw, 0, "sformat", Memc[sys], SZ_FNAME)) {
	    call mw_gwattrs (mw, 0, "system", Memc[sys], SZ_FNAME)
	    call mw_swattrs (mw, 0, "sformat", Memc[sys])
	}
	format = strdic (Memc[sys], Memc[sys], SZ_FNAME, SMW_FORMATS)

	call calloc (smw, SMW_LEN(1), TY_STRUCT)
	call malloc (SMW_APID(smw), SZ_LINE, TY_CHAR)
	SMW_FORMAT(smw) = format
	SMW_DTYPE(smw) = INDEFI
	SMW_NMW(smw) = 1
	SMW_MW(smw,0) = mw

	switch (format) {
	case SMW_ND:
#call eprintf ("smw_open: 10\n")
	    call smw_daxis (smw, im, INDEFI, INDEFI, INDEFI)
	    call smw_sax (smw, smw1, im)

	case SMW_ES:
#call eprintf ("smw_open: 20\n")
	    call smw_sax (smw, smw1, im)

	    nspec = SMW_NSPEC(smw)
	    call calloc (SMW_APS(smw), nspec, TY_INT)
	    call calloc (SMW_BEAMS(smw), nspec, TY_INT)
	    call calloc (SMW_APLOW(smw), 2*nspec, TY_REAL)
	    call calloc (SMW_APHIGH(smw), 2*nspec, TY_REAL)
	    call calloc (SMW_APIDS(smw), nspec, TY_POINTER)
	    if (SMW_PDIM(smw) > 1)
		SMW_CTLP(smw) = mw_sctran (mw, "logical", "physical", 2)

	case SMW_MS:
#call eprintf ("smw_open: 30\n")
	    call smw_sax (smw, smw1, im)

	    nspec = SMW_NSPEC(smw)
	    call calloc (SMW_APIDS(smw), nspec, TY_POINTER)
	    if (SMW_PDIM(smw) > 1)
		SMW_CTLP(smw) = mw_sctran (mw, "logical", "physical", 2)

	    nmw = 1 + (nspec - 1) / SMW_NSPLIT
	    if (nmw > 1) {
		call realloc (smw, SMW_LEN(nmw), TY_STRUCT)
		call calloc (SMW_APS(smw), nspec, TY_INT)
	    }
	    do i = 1, nmw-1
		SMW_MW(smw,i) = mw_newcopy (mw)
	    SMW_NMW(smw) = nmw
	}

	mw = smw
	    
	call sfree (sp)
end
