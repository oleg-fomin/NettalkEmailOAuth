

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('DEMO004.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('DEMO003.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form LineItems
!!! </summary>
UpdateLineItems PROCEDURE 

CurrentTab           STRING(80)                            !
ActionMessage        CSTRING(40)                           !
History::LIN:Record  LIKE(LIN:RECORD),THREAD
QuickWindow          WINDOW('Form LineItems'),AT(,,278,113),FONT('Segoe UI',10,,FONT:regular),DOUBLE,CENTER,GRAY, |
  IMM,MDI,HLP('UpdateLineItems'),SYSTEM
                       SHEET,AT(4,4,272,86),USE(?CurrentTab)
                         TAB('General'),USE(?Tab:1)
                           PROMPT('ID:'),AT(8,20),USE(?LIN:ID:Prompt),TRN
                           ENTRY(@n-14),AT(72,20,64,10),USE(LIN:ID),RIGHT(1)
                           PROMPT('Invoice Number:'),AT(8,34),USE(?LIN:InvoiceNumber:Prompt),TRN
                           ENTRY(@n-14),AT(72,34,64,10),USE(LIN:InvoiceNumber),RIGHT(1)
                           PROMPT('Product:'),AT(8,48),USE(?LIN:Product:Prompt),TRN
                           ENTRY(@n-14),AT(72,48,64,10),USE(LIN:Product),RIGHT(1)
                           PROMPT('Price:'),AT(8,62),USE(?LIN:Price:Prompt),TRN
                           ENTRY(@n-10.2),AT(72,62,48,10),USE(LIN:Price),DECIMAL(12)
                           PROMPT('Quantity:'),AT(8,76),USE(?LIN:Quantity:Prompt),TRN
                           ENTRY(@n-14),AT(72,76,64,10),USE(LIN:Quantity),RIGHT(1)
                           BUTTON('...'),AT(141,47,12,12),USE(?CallLookup)
                           STRING(@s40),AT(157,48,117),USE(PRO:Name,,?PRO:Name:2)
                         END
                       END
                       BUTTON('&OK'),AT(170,93,50,15),USE(?OK),LEFT,ICON('ok.ico'),DEFAULT,MSG('Accept data an' & |
  'd close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(224,93,50,15),USE(?Cancel),LEFT,ICON('cancel.ico'),MSG('Cancel operation'), |
  TIP('Cancel operation')
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Reset                  PROCEDURE(BYTE Force=0),DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
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
  GlobalErrors.SetProcedureName('UpdateLineItems')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?LIN:ID:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(LIN:Record,History::LIN:Record)
  SELF.AddHistoryField(?LIN:ID,1)
  SELF.AddHistoryField(?LIN:InvoiceNumber,2)
  SELF.AddHistoryField(?LIN:Product,3)
  SELF.AddHistoryField(?LIN:Price,4)
  SELF.AddHistoryField(?LIN:Quantity,5)
  SELF.AddUpdateFile(Access:LineItems)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:LineItems.SetOpenRelated()
  Relate:LineItems.Open                                    ! File LineItems used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:LineItems
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
    ?LIN:ID{PROP:ReadOnly} = True
    ?LIN:InvoiceNumber{PROP:ReadOnly} = True
    ?LIN:Product{PROP:ReadOnly} = True
    ?LIN:Price{PROP:ReadOnly} = True
    ?LIN:Quantity{PROP:ReadOnly} = True
    DISABLE(?CallLookup)
  END
  INIMgr.Fetch('UpdateLineItems',QuickWindow)              ! Restore window settings from non-volatile store
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:LineItems.Close
  END
  IF SELF.Opened
    INIMgr.Update('UpdateLineItems',QuickWindow)           ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Reset PROCEDURE(BYTE Force=0)

  CODE
  SELF.ForcedReset += Force
  IF QuickWindow{Prop:AcceptAll} THEN RETURN.
  PRO:ID = LIN:Product                                     ! Assign linking field value
  Access:Product.Fetch(PRO:Key)
  PARENT.Reset(Force)


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run()
  IF SELF.Request = ViewRecord                             ! In View Only mode always signal RequestCancelled
    ReturnValue = RequestCancelled
  END
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    BrowseProduct
    ReturnValue = GlobalResponse
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
    OF ?LIN:Product
      IF LIN:Product OR ?LIN:Product{PROP:Req}
        PRO:ID = LIN:Product
        IF Access:Product.TryFetch(PRO:Key)
          IF SELF.Run(1,SelectRecord) = RequestCompleted
            LIN:Product = PRO:ID
            LIN:Price = PRO:RRP
            LIN:Quantity = 1
          ELSE
            CLEAR(LIN:Price)
            CLEAR(LIN:Quantity)
            SELECT(?LIN:Product)
            CYCLE
          END
        ELSE
          LIN:Price = PRO:RRP
          LIN:Quantity = 1
        END
      END
      ThisWindow.Reset(1)
    OF ?CallLookup
      ThisWindow.Update()
      PRO:ID = LIN:Product
      IF SELF.Run(1,SelectRecord) = RequestCompleted
        LIN:Product = PRO:ID
        LIN:Price = PRO:RRP
        LIN:Quantity = 1
      END
      ThisWindow.Reset(1)
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

