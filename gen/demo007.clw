

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('DEMO007.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form Customer
!!! </summary>
UpdateCustomer PROCEDURE 

CurrentTab           STRING(80)                            !
ActionMessage        CSTRING(40)                           !
History::CUS:Record  LIKE(CUS:RECORD),THREAD
QuickWindow          WINDOW('Form Customer'),AT(,,251,99),FONT('Segoe UI',10,,FONT:regular),DOUBLE,CENTER,GRAY, |
  IMM,MDI,HLP('UpdateCustomer'),SYSTEM
                       SHEET,AT(4,4,237,72),USE(?CurrentTab)
                         TAB('General'),USE(?Tab:1)
                           PROMPT('ID:'),AT(8,20),USE(?CUS:ID:Prompt),TRN
                           ENTRY(@n-14),AT(64,20,64,10),USE(CUS:ID),RIGHT(1)
                           PROMPT('Name:'),AT(8,34),USE(?CUS:Name:Prompt),TRN
                           ENTRY(@s20),AT(64,34,163,10),USE(CUS:Name)
                           PROMPT('Email:'),AT(8,48),USE(?CUS:Email:Prompt),TRN
                           ENTRY(@s255),AT(64,48,163,10),USE(CUS:Email)
                         END
                       END
                       BUTTON('&OK'),AT(137,79,50,15),USE(?OK),LEFT,ICON('ok.ico'),DEFAULT,MSG('Accept data an' & |
  'd close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(191,79,50,15),USE(?Cancel),LEFT,ICON('cancel.ico'),MSG('Cancel operation'), |
  TIP('Cancel operation')
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
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
  QuickWindow{PROP:StatusText,2} = ActionMessage           ! Display status message in status bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateCustomer')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?CUS:ID:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(CUS:Record,History::CUS:Record)
  SELF.AddHistoryField(?CUS:ID,1)
  SELF.AddHistoryField(?CUS:Name,2)
  SELF.AddHistoryField(?CUS:Email,3)
  SELF.AddUpdateFile(Access:Customer)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Customer.Open                                     ! File Customer used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Customer
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
    ?CUS:ID{PROP:ReadOnly} = True
    ?CUS:Name{PROP:ReadOnly} = True
    ?CUS:Email{PROP:ReadOnly} = True
  END
  INIMgr.Fetch('UpdateCustomer',QuickWindow)               ! Restore window settings from non-volatile store
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Customer.Close
  END
  IF SELF.Opened
    INIMgr.Update('UpdateCustomer',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
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

