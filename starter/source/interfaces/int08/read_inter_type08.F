Copyright>        OpenRadioss
Copyright>        Copyright (C) 1986-2022 Altair Engineering Inc.
Copyright>    
Copyright>        This program is free software: you can redistribute it and/or modify
Copyright>        it under the terms of the GNU Affero General Public License as published by
Copyright>        the Free Software Foundation, either version 3 of the License, or
Copyright>        (at your option) any later version.
Copyright>    
Copyright>        This program is distributed in the hope that it will be useful,
Copyright>        but WITHOUT ANY WARRANTY; without even the implied warranty of
Copyright>        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Copyright>        GNU Affero General Public License for more details.
Copyright>    
Copyright>        You should have received a copy of the GNU Affero General Public License
Copyright>        along with this program.  If not, see <https://www.gnu.org/licenses/>.
Copyright>    
Copyright>    
Copyright>        Commercial Alternative: Altair Radioss Software 
Copyright>    
Copyright>        As an alternative to this open-source version, Altair also offers Altair Radioss 
Copyright>        software under a commercial license.  Contact Altair to discuss further if the 
Copyright>        commercial version may interest you: https://www.altair.com/radioss/.    
Chd|====================================================================
Chd|  READ_INTER_TYPE08             source/interfaces/int08/read_inter_type08.F
Chd|-- called by -----------
Chd|-- calls ---------------
Chd|        ANCMSG                        source/output/message/message.F
Chd|        FREERR                        source/starter/freform.F      
Chd|        NGR2USR                       source/system/nintrr.F        
Chd|        GROUPDEF_MOD                  ../common_source/modules/groupdef_mod.F
Chd|        MESSAGE_MOD                   share/message_module/message_mod.F
Chd|====================================================================
      SUBROUTINE READ_INTER_TYPE08(
     1       IPARI      ,STFAC      ,FRIGAP     ,NOINT     ,NI       ,
     2       IGRNOD     ,IGRSURF    ,FAC_M      ,FAC_T     ,FAC_L    ,
     3       TITR     )
C============================================================================
C
C-----------------------------------------------
C   M o d u l e s
C-----------------------------------------------
      USE MESSAGE_MOD
      USE GROUPDEF_MOD
C-----------------------------------------------
C   I m p l i c i t   T y p e s
C-----------------------------------------------
#include      "implicit_f.inc"
C-----------------------------------------------
C   A n a l y s e   M o d u l e
C-----------------------------------------------
C-----------------------------------------------
C   C o m m o n   B l o c k s
C-----------------------------------------------
#include      "scr17_c.inc"
#include      "sphcom.inc"
C-----------------------------------------------
C   D u m m y   A r g u m e n t s
C-----------------------------------------------
      INTEGER ISU1,ISU2,NI,NOINT
      INTEGER IPARI(*)
      my_real
     .   STFAC,FAC_M ,FAC_T,FAC_L
      my_real
     .   FRIGAP(*)
      CHARACTER TITR*nchartitle,TITR1*nchartitle
C-----------------------------------------------
      TYPE (GROUP_)  ,TARGET, DIMENSION(NGRNOD)  :: IGRNOD
      TYPE (SURF_)   ,TARGET , DIMENSION(NSURF)   :: IGRSURF
C-----------------------------------------------
C   C o m m o n   B l o c k s
C-----------------------------------------------
#include      "param_c.inc"
#include      "scr03_c.inc"
#include      "scr05_c.inc"
#include      "scr06_c.inc"
#include      "com01_c.inc"
#include      "com04_c.inc"
#include      "com09_c.inc"
#include      "intstamp_c.inc"
#include      "units_c.inc"
#include      "warn_c.inc"
#include      "scr12_c.inc"
#include      "remesh_c.inc"
#include      "sysunit.inc"
C-----------------------------------------------
C   L o c a l   V a r i a b l e s
C-----------------------------------------------
      INTEGER I,J,L, NTYP,IS1, IS2,IGSTI,ILEV,INTKG,IBUC,
     .   IFT0,IFORM,IBC1, IBC2, IBC3,IBC1M, IBC2M, IBC3M,
     .   IBID,IRM,INACTI
      my_real
     .   FRIC,GAP,STARTT,STOPT,FNOR,DBDEPTH,VISC,VISCF
      CHARACTER MESS*40, MSGTITL*nchartitle
      CHARACTER OPT*ncharkey,KEY*ncharkey,KEY1*ncharkey,
     .          BCFLAG*ncharfield, BCFLAGM*ncharfield
!
      INTEGER, DIMENSION(:), POINTER :: INGR2USR
C-----------------------------------------------
C   E x t e r n a l   F u n c t i o n s
C-----------------------------------------------
      INTEGER NGR2USR
C-----------------------------------------------
C=======================================================================
C     READING Drawbead INTERFACE /INTER/TYPE8
C=======================================================================

C Initializations
      IS1=0
      IS2=0
      IBC1=0
      IBC2=0
      IBC3=0
      IBC1M=0
      IBC2M=0
      IBC3M=0
      IGSTI = 0
      ILEV = 0  
      INTKG = 0
      IBUC = 0 
      IFORM = 0  
      INACTI = 0   
C
      FRIC = ZERO
      GAP = ZERO
      STARTT = ZERO
      STOPT=EP30
      FNOR = ZERO
      DBDEPTH =ZERO
      VISC = ZERO
      VISCF = ZERO

C
      NTYP = 8
      IPARI(15)=NOINT
      IPARI(7)=NTYP

C------------------------------------------------------------
C  Card1 :flags
C------------------------------------------------------------

      READ(IIN,REC=IREC,ERR=999,FMT='(A)')LINE
      READ(LINE,ERR=999,FMT=FMT_8I)
     .        ISU1,ISU2,IGSTI,IFORM,IFT0

C....* CHECKS *.............

      IS1=2
      IS2=1
      IF(IFORM==0)IFORM=2
      IF(IFORM==1.AND.ISTATCND/=0)THEN
            CALL ANCMSG(MSGID=703,
     .                  MSGTYPE=MSGERROR,
     .                  ANMODE=ANINFO,
     .                   I1=NOINT,
     .                   C1=TITR)
       END IF

       IPARI(48) = IFORM
       IPARI(50) = IFT0

       INGR2USR => IGRNOD(1:NGRNOD)%ID
       ISU1=NGR2USR(ISU1,INGR2USR,NGRNOD)
       IF(IGRNOD(ISU1)%SORTED/=1)THEN
           CALL ANCMSG(MSGID=112,
     .                   MSGTYPE=MSGERROR,
     .                   ANMODE=ANINFO,
     .                   I1=NOINT,
     .                   C1=TITR)
       ENDIF
       INGR2USR => IGRSURF(1:NSURF)%ID
       ISU2=NGR2USR(ISU2,INGR2USR,NSURF)

C.......* Storage IPARI FRIGAP *........
      IPARI(45)=ISU1
      IPARI(46)=ISU2
      IPARI(13)=IS1*10+IS2

C------------------------------------------------------------
C  Card2
C------------------------------------------------------------
      IREC=IREC+1
      READ(IIN,REC=IREC,ERR=999,FMT='(A)')LINE
      READ(LINE,ERR=999,FMT=FMT_5F)
     .            FNOR,FRIC,DBDEPTH,STARTT,STOPT

C.....* CHECKS *.....

      FNOR = FNOR * FAC_M / ( FAC_T * FAC_T )
      FRIC = FRIC * FAC_M / ( FAC_T * FAC_T )
      DBDEPTH = DBDEPTH * FAC_L
      STARTT = STARTT * FAC_T
      STOPT = STOPT * FAC_T
      IF (STOPT == ZERO) STOPT = EP30

C.....* Storage IPARI FRIGAP *.......
      FRIGAP(1)=FRIC
      FRIGAP(3)=STARTT
      FRIGAP(11)=STOPT
      FRIGAP(4)=FNOR
      FRIGAP(5)=DBDEPTH

C------------------------------------------------------------
C  Card3
C------------------------------------------------------------
       IREC=IREC+1
       READ(IIN,REC=IREC,ERR=999,FMT='(A)')LINE
       READ(LINE,ERR=999,FMT=FMT_A_3I_3F)
     .        BCFLAG,IBID,IRM,INACTI,VISC,VISCF

C....* CHECKS And Storage IPARI FRIGAP *.............

       IF(IFORM==2) THEN
C VISC is a non documennted parameter
            IF(VISC==ZERO) VISC=EM01
       END IF
       IF (BCFLAG(LFIELD-2:LFIELD-2) == '1') IBC1 = 1
       IF (BCFLAG(LFIELD-1:LFIELD-1) == '1') IBC2 = 1
       IF (BCFLAG(LFIELD  :LFIELD  ) == '1') IBC3 = 1

       IPARI(24) = IRM

       IF(NADMESH/=0) KCONTACT=1

        IPARI(11)=4*IBC1+2*IBC2+IBC3 + 8 *(4*IBC1M+2*IBC2M+IBC3M)
        IPARI(22)=INACTI
        FRIGAP(14)=VISC
C
        FRIGAP(2)=GAP
        IPARI(20)=ILEV
        IPARI(65) = INTKG
        IPARI(12)=IBUC
      IF (STFAC == ZERO ) STFAC = ONE_FIFTH
C
C------------------------------------------------------------
C     PRINTOUT
C------------------------------------------------------------
C
        WRITE(IOUT,1508)FRIC,FNOR,DBDEPTH,STARTT,STOPT,IRM,IFORM,IFT0

C--------------------------------------------------------------
      IF(IS1==0)THEN
        WRITE(IOUT,'(6X,A)')'NO SECONDARY SURFACE INPUT'
      ELSEIF(IS1==1)THEN
        WRITE(IOUT,'(6X,A)')'SECONDARY SURFACE INPUT BY SEGMENTS'
      ELSEIF(IS1==2)THEN
        WRITE(IOUT,'(6X,A)')'SECONDARY SURFACE INPUT BY NODES'
      ELSEIF(IS1==3)THEN
        WRITE(IOUT,'(6X,A)')'SECONDARY SURFACE INPUT BY SEGMENTS'
      ELSEIF(IS1==4 )THEN
        WRITE(IOUT,'(6X,A)')'SECONDARY SIDE INPUT BY BRICKS'
      ELSEIF(IS1==5 )THEN
        WRITE(IOUT,'(6X,A)')'SECONDARY SIDE INPUT BY SOLID ELEMENTS'        
      ENDIF
      IF(IS2==0)THEN
        WRITE(IOUT,'(6X,A)')'NO MAIN SURFACE INPUT'
      ELSEIF(IS2==1)THEN
        WRITE(IOUT,'(6X,A)')'MAIN SURFACE INPUT BY SEGMENTS'
      ELSEIF(IS2==2)THEN
        WRITE(IOUT,'(6X,A)')'MAIN SURFACE INPUT BY NODES'
      ELSEIF(IS2==3)THEN
        WRITE(IOUT,'(6X,A)')'MAIN SURFACE INPUT BY SEGMENTS'
      ELSEIF(IS2==4)THEN
        WRITE(IOUT,'(6X,A)')'MAIN SURFACE REFERS ',
     .                      'TO HYPER-ELLIPSOIDAL SURFACE'
      ENDIF
C
C--------------------------------------------------------------
 1000 FORMAT(/1X,'  INTERFACE NUMBER :',I10,1X,A)
C------------
      RETURN
 999  CALL FREERR(3)
      RETURN

 1508 FORMAT(//
     .    '    TYPE==8  DRAW-BEAD                       ' //,
     .    '    RETRAINING DRAW-BEAD FORCE / UNIT LENGTH . ',1PG20.13/,
     .    '    NORMAL DRAW-BEAD FORCE / UNIT LENGTH . . . ',1PG20.13/,
     .    '    DRAW-BEAD DEPTH . . . . . . . . . .  . . . ',1PG20.13/,
     .    '    START TIME. . . . . . . . . . . . . . . . ',1PG20.13/,
     .    '    STOP TIME . . . . . . . . . . . . . . . . ',1PG20.13/,
     .    '    MAIN SURFACE REORDERING FLAG. . . . . . ',I1/,
     .    '    FORMULATION FOR TANGENTIAL FORCE COMPUTATION',/,
     .    '            (1: VISCOUS, 2: INCREMENTAL) . . .',I1/,
     .    '    DEACTIVATION FLAG FOR RETRAINING FORCE REDUCING',I1/)

      END
