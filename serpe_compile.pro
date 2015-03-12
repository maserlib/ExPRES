.r serpe_lesia
.r orb_body
.r read_save
.r field
.r src
.r spdynps
.r spdyn
.r fit
.r movie
.r movie2d
.r m_sacred
.r ORB__DEFINE
.r IDENTITY
.r IDLEXVIEWMANIP__DEFINE
.r IDLEXINSCRIBINGVIEW__DEFINE
.r IDLEXOBJVIEW__DEFINE
.r CROSSP
.r CALDAT
RESOLVE_ALL
init_movie
RESOLVE_ALL
save,/ROUTINES,filename='SERPE.sav'
spawn,'mv SERPE.sav ../test/SERPE.sav'
