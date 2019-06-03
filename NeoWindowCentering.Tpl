#! Neo Window Centering Template to Centre SDI Window Inside Main Frame.
#!------------------------------------------------------------------------------
#TEMPLATE(NeoWindowCentering,'Template that enables Neo Window Centering to every SDI window'),FAMILY('abc')
#!------------------------------------------------------------------------------
#System
  #EQUATE(%NeoWindowCenteringTPLVersion,'1.01')
#!------------------------------------------------------------------------------
#Extension(ActivateNeoWindowCentering,'Activate Neo Window Centering - Global 1.01'),Application(LocalNeoWindowCentering(NeoWindowCentering))
#SHEET
    #TAB('Functions')
        #BOXED('')
            #DISPLAY('Neo Window Centering Version '& %NeoWindowCenteringTPLVersion)
            #DISPLAY('')
      	    #Prompt('Disable Neo Window Centering Version in this application.',Check),%GloDisableNeoWindowCentering,At(10)
            #Display('No Neo Window Centering code will be generated.')
            #Display('')
        #ENDBOXED
    #ENDTAB
    #TAB('About')
        #BOXED('')
            #DISPLAY('Neo Window Centering Version '& %NeoWindowCenteringTPLVersion)
            #DISPLAY('32 Bit only')
            #DISPLAY('')            
            #DISPLAY('Copyright (C) 2019 by Bostjan Laba')
            #DISPLAY('E-Mail: bostjan@neolink.si')
            #DISPLAY('Web: https://github.com/bostjanlaba')
            #DISPLAY('All Rights Reserved')
            #DISPLAY('')
            #DISPLAY('Credits to Lee White and Johan de Klerk')
            #DISPLAY('')
        #ENDBOXED
    #ENDTAB
#ENDSHEET
#!#################################################################################################
#! End of GLOBAL EXTENSION
#!#################################################################################################
#AT(%GlobalData),Where(%GloDisableNeoWindowCentering=0 and %ProgramExtension='EXE' and %AppTemplateFamily='ABC'),DESCRIPTION('Declare Neo Window Centering Global Variables')
#INSERT(%NeoWindowCenteringGlobalData)
#ENDAT
#!------------------------------------------------------------------------------
#Extension(LocalFrameNeoWindowCentering,'Neo Window Centering Frame Object - Local 1.01') #!,Procedure,req(ActivateNeoWindowCentering(NeoWindowCentering))
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)='FRAME')
#ENDRESTRICT
#BOXED('')
    #DISPLAY('Neo Window Centering Version '& %NeoWindowCenteringTPLVersion),At(10,4)
    #DISPLAY('')
    #Prompt('Disable Neo Window Centering in this Procedure.',Check),%DisableNeoWindowCenteringLocalFrame,At(10,16)
    #DISPLAY('')
#ENDBOXED
#AT(%WindowManagerMethodCodeSection, 'Init', '(),BYTE'),LAST,WHERE(%GloDisableNeoWindowCentering=0 and %DisableNeoWindowCenteringLocalFrame=0 and %ProgramExtension='EXE' and %AppTemplateFamily='ABC'),DESCRIPTION('Declare Neo Window Centering Init'),Priority(8001)
  #INSERT(%NeoWindowCenteringFrameAfterOpenWindow)
#ENDAT
#!------------------------------------------------------------------------------
#Extension(LocalNeoWindowCentering,'Neo Window Centering SDI Object - Local 1.01') #!,Procedure,req(ActivateNeoWindowCentering(NeoWindowCentering))
#RESTRICT,WHERE(~EXTRACT(%WindowStatement,'MDI'))
#ENDRESTRICT
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'FRAME')
#ENDRESTRICT
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'SOURCE')
#ENDRESTRICT
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'REPORT')
#ENDRESTRICT
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'EXTERNAL')
#ENDRESTRICT
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'MENU')
#ENDRESTRICT
#BOXED('')
    #DISPLAY('Neo Window Centering Version '& %NeoWindowCenteringTPLVersion),At(10,4)
    #DISPLAY('')
    #Prompt('Disable Neo Window Centering in this Procedure.',Check),%DisableNeoWindowCenteringLocalSDI,At(10,16)
    #DISPLAY('')
#ENDBOXED
#AT(%WindowManagerMethodCodeSection, 'Init', '(),BYTE'),LAST,WHERE(%GloDisableNeoWindowCentering=0 and %DisableNeoWindowCenteringLocalSDI=0 and %AppTemplateFamily='ABC'),DESCRIPTION('Declare Neo Window Centering Init'),Priority(8001)
  #INSERT(%NeoWindowCenteringSDIAfterOpenWindow)
#ENDAT
#AT(%ProcedureRoutines,'()'),LAST,WHERE(%GloDisableNeoWindowCentering=0 and %DisableNeoWindowCenteringLocalSDI=0 and %AppTemplateFamily='ABC'),DESCRIPTION('Declare Neo Window Centering Routine'),Priority(8001)
#INSERT(%NeoWindowCenteringSDIProcedureRoutines)
#ENDAT

#!------------------------------------------------------------------------------
#GROUP(%NeoWindowCenteringGlobalData)
!Start Neo Window Centering - Global Data
AppFrameRef          &WINDOW 
!End Neo Window Centering - Global Data
#!------------------------------------------------------------------------------
#GROUP(%NeoWindowCenteringFrameAfterOpenWindow)
!Start Neo Window Centering - Frame WindowManagerMethodCodeSection Init
AppFrameRef &= AppFrame 
!End Neo Window Centering - Frame WindowManagerMethodCodeSection Init
#!------------------------------------------------------------------------------
#GROUP(%NeoWindowCenteringSDIAfterOpenWindow)
!Start Neo Window Centering - SDI Window WindowManagerMethodCodeSection Init
DO NeoWindowCentering
!End Neo Window Centering - SDI Window WindowManagerMethodCodeSection Init
#!------------------------------------------------------------------------------
#GROUP(%NeoWindowCenteringSDIProcedureRoutines)
!Start Neo Window Centering - SDI Window Procedure Routines 
NeoWindowCentering	ROUTINE

    AppFrameRef{PROP:Pixels} = TRUE 
    0{PROP:Pixels}           = TRUE 
    SETPOSITION(0,AppFrameRef{PROP:Width}/2-0{PROP:Width}/2,AppFrameRef{PROP:Height}/2-0{PROP:Height}/2) 
    0{PROP:Pixels}           = FALSE 
    AppFrameRef{PROP:Pixels} = FALSE 
!End Neo Window Centering - SDI Window Procedure Routines 