 #! Neo Font Resizer Template to Resize Window and Fonts.
#!------------------------------------------------------------------------------
 #TEMPLATE(NeoFontResizer,'Template that applies Neo Font Resizer Resize to every window'),FAMILY('abc')
 #!------------------------------------------------------------------------------
 #System
  #EQUATE(%NeoFontResizerTPLVersion,'1.05')
#!------------------------------------------------------------------------------
#Extension(ActivateNeoFontResizer,'Activate Neo Font Resizer - Global 1.05'),Application(LocalNeoFontResizer(NeoFontResizer))
#SHEET
 #TAB('Functions')
  #BOXED('')
     #DISPLAY('Neo Font Resizer Version '& %NeoFontResizerTPLVersion)
     #DISPLAY('')
     #Display('Use NFRDisable=True before opening the window')
     #DISPLAY('to disable resizing at runtime.')
     #DISPLAY('')
     #Display('Call NFRReset() to reset font sizes')
     #DISPLAY('to original size when window is open.')
     #DISPLAY('')
     #Display('Call NFRSet() to set font sizes')
     #DISPLAY('to proportional size when window is open.')
     #DISPLAY('')
   #ENDBOXED
  #ENDTAB
  #TAB('About')
   #BOXED('')
      #DISPLAY('Neo Font Resizer Version '& %NeoFontResizerTPLVersion)
      #DISPLAY('32 Bit only')
      #DISPLAY('')
      #DISPLAY('Copyright (C) 2018 by Bostjan Laba')
      #DISPLAY('E-Mail: bostjan@neolink.si')
      #DISPLAY('All Rights Reserved')
      #DISPLAY('')
    #ENDBOXED
   #ENDTAB
#ENDSHEET
#!#################################################################################################
#! End of GLOBAL EXTENSION
#!#################################################################################################
#Extension(LocalNeoFontResizer,'Neo Font Resizer Object - Local 1.05') #!,Procedure,req(ActivateNeoFontResizer(NeoFontResizer))
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'SOURCE')
#ENDRESTRICT
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'REPORT')
#ENDRESTRICT
#RESTRICT,WHERE(%CResizeHasTemplate('WindowResize(ABC)'))
#ENDRESTRICT
#BOXED('')
   #DISPLAY('Neo Font Resizer Version '& %NeoFontResizerTPLVersion),At(10,4)
   #DISPLAY('')
   #Prompt('Disable Neo Font Resizer in this Procedure.',Check),%DisableNeoFontResizerLocal,At(10,16)
   #DISPLAY('')
   #Display('Use NFRDisable=True before opening the window')
   #DISPLAY('to disable resizing at runtime.')
   #DISPLAY('')
   #Display('Call NFRReset() to reset font sizes')
   #DISPLAY('to original size when window is open.')
   #DISPLAY('')
   #Display('Call NFRSet() to set font sizes')
   #DISPLAY('to proportional size when window is open.')
   #DISPLAY('')
#ENDBOXED
#AT(%LocalDataAfterClasses),PRIORITY(4000),Where(%DisableNeoFontResizerLocal=%false),Description('Neo Font Resizer (local) - Data Declaration')
!Added by Neo Font Resizer - START (DATA SECTION)
	MAP
NFRSet								Procedure
NFRReset							Procedure
	END
StartXpos           LONG
StartYpos           LONG
StartWidth          LONG
StartHeight         LONG
StartFont           LONG
ThisField           LONG(0)
WidthRatio          DECIMAL(5,1)
HeightRatio         DECIMAL(5,1)
Ratio               DECIMAL(5,1)
NFRDisable					 BYTE

ListQueue   QUEUE
Id              LONG,Name('qid')
ListHeight      LONG
FontSize        LONG
ColumnId        LONG,Name('cid')
ColumnWidth     LONG
            END
ControlQueue  QUEUE
Id              LONG
FontSize        LONG
            END
!Added by Neo Font Resizer - END (DATA SECTION)
#ENDAT
#!------------------------------------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),Where(%DisableNeoFontResizerLocal=%false),PRIORITY(8001),Description('Neo Font Resizer (local) - ABC Init')
    !Added by Neo Font Resizer - START (AFTER WINDOW OPEN SECTION)
    GETPOSITION(0,StartXpos,StartYpos,StartWidth,StartHeight)
    !StartFont = 0{Prop:FontSize} !Fontsize of the whole window
    FREE(listqueue)
    LOOP
        ThisField = 0{Prop:NextField,ThisField}  !Process every control
        IF ThisField
            IF thisfield{Prop:Type} = Create:List
                ListQueue:Id         = ThisField
                ListQueue:ListHeight = ThisField{Prop:LineHeight}
                ListQueue:FontSize   = Thisfield{Prop:FontSize}
                columns#             = 1
                LOOP WHILE thisfield{PropList:Exists,columns#}
                    listqueue:columnid    = columns#
                    listqueue:columnwidth = thisfield{PropList:Width,columns#}
                    ADD(ListQueue)
                    columns# += 1
                END
                columns# = 0
            END
            IF ThisField{prop:type} <> Create:List
                  ControlQueue:Id = ThisField
                  ControlQueue:FontSize = ThisField {prop:fontsize}
                  ADD(ControlQueue)
            END
        ELSE
            BREAK !Break when done
        END
    END
    !Added by Neo Font Resizer - END (AFTER WINDOW OPEN SECTION)
#ENDAT
#!------------------------------------------------------------------------------
#AT(%ResizerMethodCodeSection),Where(%DisableNeoFontResizerLocal=%false AND %pClassMethod='Resize' AND %pClassMethodPrototype='(),BYTE'),PRIORITY(5001),DESCRIPTION('Neo Font Resizer (local) - Resizer Section')
    !Added by Neo Font Resizer - START (RESIZER SECTION)�
    If NFRDisable=False 	!Resizing remains enabled
    	 NFRSet()						!Call the procedure to resize fonts
    END
    !Added by Neo Font Resizer - END (RESIZER SECTION)
#ENDAT
#!------------------------------------------------------------------------------
#At(%WindowManagerMethodCodeSection,'Kill','(),BYTE'),Where(%DisableNeoFontResizerLocal=%false),Priority(5001),DESCRIPTION('Neo Font Resizer (local) - Kill Section')
    !Added by Neo Font Resizer - START (KILL SECTION)
    FREE(listqueue)
    !Added by Neo Font Resizer - END (KILL SECTION)
#ENDAT
#!------------------------------------------------------------------------------
#At(%LocalProcedures,,'(),BYTE'),Where(%DisableNeoFontResizerLocal=%false),Priority(8001),DESCRIPTION('Neo Font Resizer (local) - Reset Procedure')
    !Added by Neo Font Resizer - START (LOCAL PROCEDURE SECTION)
NFRSet    PROCEDURE
    CODE
   	WidthRatio  = 0{Prop:At,3}/startwidth
    	HeightRatio = 0{Prop:At,4}/startheight
    	IF widthratio < heightratio
      	  ratio = widthratio
    	ELSE
      	  ratio = heightratio
    	END
    	LOOP
      	  ThisField = 0{Prop:NextField,ThisField}  !Process every control
        	IF ThisField
          	  IF thisfield{Prop:Type} <> Create:List AND thisfield{Prop:Type} <> Create:Menu AND thisfield{Prop:Type} <> Create:MenuBar AND thisfield{Prop:Type} <> Create:Item
                 Controlqueue:Id=ThisField
                 get(ControlQueue,ControlQueue:Id)
           	     ThisField{Prop:FontSize} = ROUND(ControlQueue:FontSize * Ratio,1)
            	END
            	IF thisfield{Prop:Type} = Create:List
             	   listqueue:id = thisfield
               	 GET(listqueue,listqueue:id)
                	ThisField{Prop:LineHeight} = ROUND(listqueue:listheight * Ratio,1)
                	ThisField{Prop:FontSize}   = ROUND(listqueue:fontsize * Ratio,1)
                	columns#                   = 1
                	LOOP WHILE thisfield{PropList:Exists,columns#}
                	    listqueue:id       = thisfield
                	    listqueue:columnid = columns#
                	    GET(listqueue,'qid,cid')
                	    thisfield{PropList:Width,columns#} = ROUND(listqueue:columnwidth * Ratio,1)
                	    columns# += 1
                	END
            	END
        	ELSE
          	  BREAK !Break when done
        	END
    	END
 RETURN
NFRReset    PROCEDURE
    CODE
    	LOOP
      	  ThisField = 0{Prop:NextField,ThisField}  !Process every control
        	IF ThisField
          	  IF thisfield{Prop:Type} <> Create:List AND thisfield{Prop:Type} <> Create:Menu AND thisfield{Prop:Type} <> Create:MenuBar AND thisfield{Prop:Type} <> Create:Item
           	     ThisField{Prop:FontSize} = StartFont
            	END
            	IF thisfield{Prop:Type} = Create:List
             	   listqueue:id = thisfield
               	 GET(listqueue,listqueue:id)
                	ThisField{Prop:LineHeight} = listqueue:listheight
                	ThisField{Prop:FontSize}   = listqueue:fontsize
                	columns#                   = 1
                	LOOP WHILE thisfield{PropList:Exists,columns#}
                	    listqueue:id       = thisfield
                	    listqueue:columnid = columns#
                	    GET(listqueue,'qid,cid')
                	    thisfield{PropList:Width,columns#} = listqueue:columnwidth
                	    columns# += 1
                	END
            	END
        	ELSE
          	  BREAK !Break when done
        	END
    	END
 RETURN
    !Added by Neo Font Resizer - END (LOCAL PROCEDURE SECTION)
#ENDAT
#! -------------------------------------------------------------------------
#GROUP(%CResizeHasTemplate,STRING %PassedTemplate),AUTO,PRESERVE
  #FOR(%ActiveTemplate),WHERE(%ActiveTemplate=%PassedTemplate)
     #RETURN(%True)
  #ENDFOR
  #RETURN(%False)
#!-------------------------------------------------------------------------
