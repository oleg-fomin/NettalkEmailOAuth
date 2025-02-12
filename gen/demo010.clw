

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('DEMO010.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form EmailSettings
!!! </summary>
UpdateEmailSettings PROCEDURE 

CurrentTab           STRING(80)                            !
ActionMessage        CSTRING(40)                           !
History::emSet:Record LIKE(emSet:RECORD),THREAD
QuickWindow          WINDOW('Send Email Settings'),AT(,,367,164),FONT('Segoe UI',10,,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateEmailSettings'),SYSTEM
                       SHEET,AT(4,4,357,133),USE(?CurrentTab)
                         TAB('General'),USE(?Tab:1)
                           PROMPT('Email Server:'),AT(10,20),USE(?emSet:EmailServer:Prompt),TRN
                           ENTRY(@s255),AT(66,20,286,10),USE(emSet:EmailServer)
                           PROMPT('Email Port:'),AT(10,33),USE(?emSet:EmailPort:Prompt),TRN
                           ENTRY(@n-14),AT(66,34,64,10),USE(emSet:EmailPort),RIGHT(1)
                           CHECK('Always TLS'),AT(66,48,70,8),USE(emSet:AlwaysSSL),RIGHT,TRN
                           CHECK('Start TLS'),AT(67,59,70,8),USE(emSet:StartTLS),RIGHT,TRN
                           PROMPT('SSL Method:'),AT(10,71),USE(?emSet:SSLMethod:Prompt),TRN
                           PROMPT('Username:'),AT(10,84),USE(?emSet:Username:Prompt),TRN
                           ENTRY(@s255),AT(66,84,286,10),USE(emSet:Username)
                           PROMPT('Password:'),AT(10,97),USE(?emSet:Password:Prompt),TRN
                           ENTRY(@s255),AT(66,98,286,10),USE(emSet:Password)
                           PROMPT('From Address:'),AT(10,111),USE(?emSet:FromAddress:Prompt),TRN
                           ENTRY(@s255),AT(66,112,286,10),USE(emSet:FromAddress)
                           OPTION('option1'),AT(67,70,286,11),USE(emSet:SSLMethod),TRN
                             RADIO('Any TLS'),AT(70,71),USE(?OPTION1:RADIO1),TRN,VALUE('-1')
                             RADIO('TLS 1.0'),AT(124,71),USE(?OPTION1:RADIO2),TRN,VALUE('3')
                             RADIO('TLS 1.1'),AT(176,71),USE(?OPTION1:RADIO3),TRN,VALUE('4')
                             RADIO('TLS 1.2'),AT(227,71),USE(?OPTION1:RADIO4),TRN,VALUE('5')
                             RADIO('TLS 1.3'),AT(279,71),USE(?OPTION1:RADIO5),TRN,VALUE('6')
                           END
                         END
                       END
                       BUTTON('&OK'),AT(257,144,50,14),USE(?OK),DEFAULT,MSG('Accept data and close the window'),TIP('Accept dat' & |
  'a and close the window')
                       BUTTON('&Cancel'),AT(311,144,50,14),USE(?Cancel),MSG('Cancel operation'),TIP('Cancel operation')
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Ask PROCEDURE

  CODE
  CASE SELF.Request                                        ! Configure the action message text
  OF ViewRecord
    ActionMessage = 'View Record'
  OF InsertRecord
    ActionMessage = 'Record Will Be Added'
  OF ChangeRecord
    ActionMessage = 'Record Will Be Changed'
  END
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateEmailSettings')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?emSet:EmailServer:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(emSet:Record,History::emSet:Record)
  SELF.AddHistoryField(?emSet:EmailServer,2)
  SELF.AddHistoryField(?emSet:EmailPort,3)
  SELF.AddHistoryField(?emSet:AlwaysSSL,4)
  SELF.AddHistoryField(?emSet:StartTLS,5)
  SELF.AddHistoryField(?emSet:Username,7)
  SELF.AddHistoryField(?emSet:Password,8)
  SELF.AddHistoryField(?emSet:FromAddress,9)
  SELF.AddHistoryField(?emSet:SSLMethod,6)
  SELF.AddUpdateFile(Access:EmailSettings)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:EmailSettings.Open                                ! File EmailSettings used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:EmailSettings
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.ChangeAction = Change:Caller                      ! Changes allowed
    SELF.CancelAction = Cancel:Cancel+Cancel:Query         ! Confirm cancel
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?emSet:EmailServer{PROP:ReadOnly} = True
    ?emSet:EmailPort{PROP:ReadOnly} = True
    ?emSet:Username{PROP:ReadOnly} = True
    ?emSet:Password{PROP:ReadOnly} = True
    ?emSet:FromAddress{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateEmailSettings',QuickWindow)          ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:EmailSettings.Close
  END
  IF SELF.Opened
    INIMgr.Update('UpdateEmailSettings',QuickWindow)       ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

str  StringTheory
  CODE
  GlobalRequest = changeRecord
  Access:EmailSettings.Open()
  Access:EmailSettings.UseFile()
  If Records(EmailSettings) < 1
    clear(emSet:record)
    emSet:Guid = str.MakeGuid()
    emSet:EmailPort = 25
    emSet:SSLMethod = NET:SSLMethodTLS
    Access:EmailSettings.Insert()
  else
    set(emSet:KeyGuid)
    Access:EmailSettings.Next()
  End  
  ReturnValue = PARENT.Run()
  IF SELF.Request = ViewRecord                             ! In View Only mode always signal RequestCancelled
    ReturnValue = RequestCancelled
  END
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?OK
      ThisWindow.Update()
      IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing THEN
         POST(EVENT:CloseWindow)
      END
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

