#! Neo Font Resizer Template to Resize Window and Fonts.
#!------------------------------------------------------------------------------
#TEMPLATE(NeoFontResizer,'Template that applies Neo Font Resizer Resize to every window'),FAMILY('abc')
#!------------------------------------------------------------------------------
#System
  #EQUATE(%NeoFontResizerTPLVersion,'1.14')
#!------------------------------------------------------------------------------
#Extension(ActivateNeoFontResizer,'Activate Neo Font Resizer - Global 1.14'),Application(LocalNeoFontResizer(NeoFontResizer))
#SHEET
    #TAB('Functions')
        #BOXED('')
            #DISPLAY('Neo Font Resizer Version '& %NeoFontResizerTPLVersion)
            #DISPLAY('')
            #DISPLAY('VERY IMPORTANT:')
            #DISPLAY('Remember to set the Resize Strategy = RESIZE')
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

#AT(%GlobalData),PRIORITY(4100),Description('Neo Font Resizer (global) - Data Declaration '& %NeoFontResizerTPLVersion)
!Added by Neo Font Resizer - START (GLOBAL DATA SECTION)

NFRGlobalStartXpos           LONG
NFRGlobalStartYpos           LONG
NFRGlobalStartWidth          LONG
NFRGlobalStartHeight         LONG
NFRGlobalEndWidth             LONG
NFRGlobalEndHeight           LONG
NFRGlobalStartFont           LONG
NFRGlobalThisField           LONG(0)
NFRGlobalWidthRatio          DECIMAL(6,3)
NFRGlobalHeightRatio         DECIMAL(6,3)
NFRGlobalRatio               DECIMAL(6,3)
NFRGlobalToolbarHeight           LONG   

!Added by Neo Font Resizer - END (GLOBAL DATA SECTION)
#ENDAT
#!#################################################################################################
#! End of GLOBAL EXTENSION
#!#################################################################################################
#Extension(LocalNeoFontResizer,'Neo Font Resizer Object - Local 1.14') #!,Procedure,req(ActivateNeoFontResizer(NeoFontResizer))
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'SOURCE')
#ENDRESTRICT
#RESTRICT,WHERE(UPPER(%ProcedureTemplate)<>'REPORT')
#ENDRESTRICT
#RESTRICT,WHERE(%ActiveTemplate <> 'WindowResize(ABC)')
#ENDRESTRICT  
#BOXED('')
    #DISPLAY('Neo Font Resizer Version '& %NeoFontResizerTPLVersion),At(10,4)
    #DISPLAY('')
    #Prompt('Disable Neo Font Resizer in this Procedure.',Check),%DisableNeoFontResizerLocal,At(10,16)
    #DISPLAY('')    
    #Prompt('Proportionally auto-resize and center window. (does not apply to Frame Procedure)',Check),%NFREnableWindowAutoResize,At(10,28)    
    #DISPLAY('')    
    #DISPLAY('VERY IMPORTANT:')
    #DISPLAY('Remember to set the Resize Strategy = RESIZE')
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
#AT(%LocalDataAfterClasses),PRIORITY(4000),Where(%DisableNeoFontResizerLocal=%false),Description('Neo Font Resizer (local) - Data Declaration '& %NeoFontResizerTPLVersion)
!Added by Neo Font Resizer - START (DATA SECTION)
    MAP
NFRSet                              Procedure
NFRReset                            Procedure
NFRAutoResize                       Procedure

    END
NFRStartXpos           LONG
NFRStartYpos           LONG
NFRStartWidth          LONG
NFRStartHeight         LONG
NFRStartFont           LONG
NFRThisField           LONG(0)
NFRWidthRatio          DECIMAL(5,1)
NFRHeightRatio         DECIMAL(5,1)
NFRRatio               DECIMAL(5,1)
NFRDisable             BYTE
NFRColumns             LONG

NFRListQueue   QUEUE
Id              LONG,Name('qid')
ListHeight      LONG
FontSize        LONG
ColumnId        LONG,Name('cid')
ColumnWidth     LONG
DropWidth       LONG   !added
            END
NFRControlsQueue  QUEUE
Id              LONG
FontSize        LONG
            END
!Added by Neo Font Resizer - END (DATA SECTION)
#ENDAT
#!------------------------------------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),Where(%DisableNeoFontResizerLocal=%false),PRIORITY(8051),Description('Neo Font Resizer (local) - ABC Init '& %NeoFontResizerTPLVersion)
    !Added by Neo Font Resizer - START (AFTER WINDOW OPEN SECTION)
    GETPOSITION(0,NFRStartXpos,NFRStartYpos,NFRStartWidth,NFRStartHeight)
    #IF (INSTRING('APPLICATION',%WindowStatement,1,1)>0) 
      !Set global properties for Frame     
        GETPOSITION(0,NFRGlobalStartXpos,NFRGlobalStartYpos,NFRGlobalStartWidth,NFRGlobalStartHeight)
    #ENDIF
    !Set IMM and CENTER attributes to current WINDOW
    If %NFREnableWindowAutoResize=True and UPPER('%ProcedureTemplate')<>'FRAME' and|
          (NFRGlobalWidthRatio<>1 or NFRGlobalHeightRatio<>1)       
          0{prop:imm}=True
          0{prop:center}=True
        End    
    FREE(NFRlistqueue)
    LOOP
        NFRThisField = 0{Prop:NextField,NFRThisField}  !Process every control
        IF NFRThisField
            IF NFRthisfield{Prop:Type}  = Create:List or  NFRthisfield{Prop:Type} = Create:Combo
                NFRListQueue:Id         = NFRThisField
                NFRListQueue:ListHeight = NFRThisField{Prop:LineHeight}
                NFRListQueue:FontSize   = NFRThisfield{Prop:FontSize}
                if NFRthisfield{PROP:DropWidth}>0
                     NFRListQueue:DropWidth  = NFRthisfield{PROP:DropWidth}
                END
                NFRcolumns              = 1
                LOOP WHILE NFRthisfield{PropList:Exists,nfrcolumns}
                    NFRlistqueue:Columnid    = NFRcolumns
                    NFRlistqueue:Columnwidth = NFRthisfield{PropList:Width,NFRcolumns}
                    ADD(NFRListQueue)
                    NFRcolumns += 1
                END
                NFRcolumns = 0
            END
            IF NFRThisField{prop:type} <> Create:List and NFRThisField{prop:type} <> Create:Combo
                  NFRControlsQueue:Id = NFRThisField
                  NFRControlsQueue:FontSize = NFRThisField {prop:fontsize}
                  ADD(NFRControlsQueue)
            END
            IF NFRThisField{prop:type} = Create:Toolbar
                  NFRGlobalToolbarHeight=NFRThisField{prop:at,4}                  
            END
        ELSE
            BREAK !Break when done
        END
    END
    !NFRAutoResize() !call window auto resizer
    !Added by Neo Font Resizer - END (AFTER WINDOW OPEN SECTION)
#ENDAT
#!------------------------------------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),Where(%DisableNeoFontResizerLocal=%false),PRIORITY(8251),Description('Neo Font Resizer (local) - ABC Init '& %NeoFontResizerTPLVersion)
    !Added by Neo Font Resizer - START (AFTER RESIZER INIT SECTION)
    NFRAutoResize()
#ENDAT
#!------------------------------------------------------------------------------
#AT(%ResizerMethodCodeSection),Where(%DisableNeoFontResizerLocal=%false AND %pClassMethod='Resize' AND %pClassMethodPrototype='(),BYTE'),PRIORITY(5001),DESCRIPTION('Neo Font Resizer (local) - Resizer Section '& %NeoFontResizerTPLVersion)
    !Added by Neo Font Resizer - START (RESIZER SECTION)?
    If NFRDisable=False     !Resizing remains enabled
         NFRSet()                        !Call the procedure to resize fonts
    END
    !Added by Neo Font Resizer - END (RESIZER SECTION)
#ENDAT
#!------------------------------------------------------------------------------
#At(%WindowManagerMethodCodeSection,'Kill','(),BYTE'),Where(%DisableNeoFontResizerLocal=%false),Priority(5001),DESCRIPTION('Neo Font Resizer (local) - Kill Section '& %NeoFontResizerTPLVersion)
    !Added by Neo Font Resizer - START (KILL SECTION)
    FREE(NFRlistqueue)
    FREE(NFRControlsQueue)
    !Added by Neo Font Resizer - END (KILL SECTION)
#ENDAT
#!------------------------------------------------------------------------------
#At(%LocalProcedures,,'(),BYTE'),Where(%DisableNeoFontResizerLocal=%false),Priority(8001),DESCRIPTION('Neo Font Resizer (local) - Reset Procedure '& %NeoFontResizerTPLVersion)
    !Added by Neo Font Resizer - START (LOCAL PROCEDURE SECTION)
NFRSet    PROCEDURE
    CODE      
       NFRWidthRatio  = 0{Prop:At,3}/NFRstartwidth
        NFRHeightRatio = 0{Prop:At,4}/NFRstartheight
        IF NFRwidthratio < NFRheightratio
            NFRratio = NFRwidthratio
        ELSE
            NFRratio = NFRheightratio
        END
        #IF (INSTRING('APPLICATION',%WindowStatement,1,1)>0)      
            !Global properties defined when Frame gets resized
            NFRGlobalWidthRatio  = 0{Prop:At,3}/NFRGlobalstartwidth
                 NFRGlobalHeightRatio = 0{Prop:At,4}/NFRGlobalstartheight
                 NFRGlobalEndWidth=0{Prop:At,3}
                 NFRGlobalEndHeight=0{Prop:At,4}
                 IF NFRGlobalwidthratio < NFRGlobalheightratio
               NFRGlobalratio = NFRGlobalwidthratio
            ELSE
               NFRGlobalratio = NFRGlobalheightratio
                 END
        #ENDIF
        LOOP
            NFRThisField = 0{Prop:NextField,NFRThisField}  !Process every control
            IF NFRThisField
                IF NFRthisfield{Prop:Type} <> Create:List AND NFRthisfield{Prop:Type} <> Create:Menu AND NFRthisfield{Prop:Type} <> Create:MenuBar AND NFRthisfield{Prop:Type} <> Create:Item AND NFRthisfield{Prop:Type} <> Create:Combo  !added combo
                 NFRControlsqueue:Id=NFRThisField
                 get(NFRControlsQueue,NFRControlsQueue:Id)
                    NFRThisField{Prop:FontSize} = ROUND(NFRControlsQueue:FontSize * NFRRatio,1)
                END
                IF NFRthisfield{Prop:Type} = Create:List or NFRthisfield{Prop:Type} = Create:Combo  !added combo
                    NFRlistqueue:id = NFRthisfield
                    GET(NFRlistqueue,NFRlistqueue:id)
                    NFRThisField{Prop:LineHeight} = ROUND(NFRlistqueue:listheight * NFRRatio,1)
                    NFRThisField{Prop:FontSize}   = ROUND(NFRlistqueue:fontsize * NFRRatio,1)
                    if NFRlistqueue:DropWidth>0
                        NFRthisfield{PROP:DropWidth}  = ROUND(NFRListQueue:DropWidth * NFRRatio,1) !added
                    END
                    NFRcolumns                   = 1
                    LOOP WHILE NFRthisfield{PropList:Exists,NFRcolumns}
                        NFRlistqueue:id       = NFRthisfield
                        NFRlistqueue:columnid = NFRcolumns
                        GET(NFRlistqueue,'qid,cid')
                        NFRthisfield{PropList:Width,NFRcolumns} = ROUND(NFRlistqueue:columnwidth * NFRRatio,1)
                        NFRcolumns += 1
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
            NFRThisField = 0{Prop:NextField,NFRThisField}  !Process every control
            IF NFRThisField
                IF NFRthisfield{Prop:Type} <> Create:List AND NFRthisfield{Prop:Type} <> Create:Menu AND NFRthisfield{Prop:Type} <> Create:MenuBar AND NFRthisfield{Prop:Type} <> Create:Item AND NFRthisfield{Prop:Type} <> Create:Combo !added combo
                 NFRControlsqueue:Id=NFRThisField
                 get(NFRControlsQueue,NFRControlsQueue:Id)
                 NFRThisField{Prop:FontSize} = NFRControlsQueue:FontSize
                END
                IF NFRthisfield{Prop:Type} = Create:List or NFRthisfield{Prop:Type} = Create:Combo !added combo
                    NFRlistqueue:id = NFRthisfield
                    GET(NFRlistqueue,NFRlistqueue:id)
                    NFRThisField{Prop:LineHeight} = NFRlistqueue:listheight
                    NFRThisField{Prop:FontSize}   = NFRlistqueue:fontsize
                    NFRcolumns                   = 1
                    if NFRthisfield{PROP:DropWidth}>0
                         NFRListQueue:DropWidth  = NFRthisfield{PROP:DropWidth}
                    END
                    LOOP WHILE NFRthisfield{PropList:Exists,NFRcolumns}
                        NFRlistqueue:id       = NFRthisfield
                        NFRlistqueue:columnid = NFRcolumns
                        GET(NFRlistqueue,'qid,cid')
                        NFRthisfield{PropList:Width,NFRcolumns} = NFRlistqueue:columnwidth
                        NFRcolumns += 1
                    END
                END
            ELSE
                BREAK !Break when done
            END
        END
 RETURN
NFRAutoResize    PROCEDURE
#DECLARE(%ResizerExists)
#SET(%ResizerExists,0)
#For(%ActiveTemplate),Where(%ActiveTemplate='WindowResize(ABC)')
  #SET(%ResizerExists,1)
  #BREAK
#ENDFOR
    CODE
        If %NFREnableWindowAutoResize=True and UPPER('%ProcedureTemplate')<>'FRAME' and|
          (NFRGlobalWidthRatio<>1 or NFRGlobalHeightRatio<>1)          
          !AutoResize          
          0{prop:at,3}=NFRStartWidth*NFRGlobalWidthRatio
          0{prop:at,4}=NFRStartHeight*NFRGlobalHeightRatio
          0{prop:at,1}=NFRGlobalEndWidth/2-0{prop:at,3}/2
          0{prop:at,2}=NFRGlobalEndHeight/2-0{prop:at,4}/2-NFRGlobalToolbarHeight
          #IF (%ResizerExists=1)                     
           Resizer.resize()
           nfrset()
          #ENDIF
        end              
      RETURN
    !Added by Neo Font Resizer - END (LOCAL PROCEDURE SECTION)
#ENDAT
