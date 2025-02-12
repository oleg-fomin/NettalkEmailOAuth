

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('DEMO005.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('DEMO004.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form Invoice
!!! </summary>
UpdateInvoice PROCEDURE 

CurrentTab           STRING(80)                            !
ActionMessage        CSTRING(40)                           !
BRW5::View:Browse    VIEW(LineItems)
                       PROJECT(LIN:ID)
                       PROJECT(LIN:Price)
                       PROJECT(LIN:Quantity)
                       PROJECT(LIN:InvoiceNumber)
                       PROJECT(LIN:Product)
                       JOIN(PRO:Key,LIN:Product)
                         PROJECT(PRO:Name)
                         PROJECT(PRO:ID)
                       END
                     END
Queue:Browse         QUEUE                            !Queue declaration for browse/combo box using ?List
LIN:ID                 LIKE(LIN:ID)                   !List box control field - type derived from field
PRO:Name               LIKE(PRO:Name)                 !List box control field - type derived from field
LIN:Price              LIKE(LIN:Price)                !List box control field - type derived from field
LIN:Quantity           LIKE(LIN:Quantity)             !List box control field - type derived from field
LIN:InvoiceNumber      LIKE(LIN:InvoiceNumber)        !Browse key field - type derived from field
PRO:ID                 LIKE(PRO:ID)                   !Related join file key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
History::INV:Record  LIKE(INV:RECORD),THREAD
QuickWindow          WINDOW('Form Invoice'),AT(,,273,167),FONT('Segoe UI',10,,FONT:regular),DOUBLE,CENTER,GRAY, |
  IMM,MDI,HLP('UpdateInvoice'),SYSTEM
                       SHEET,AT(4,4,259,140),USE(?CurrentTab)
                         TAB('General'),USE(?Tab:1)
                           PROMPT('ID:'),AT(8,20),USE(?INV:ID:Prompt),TRN
                           ENTRY(@n-14),AT(61,20,64,10),USE(INV:ID),RIGHT(1)
                           PROMPT('Customer:'),AT(8,34),USE(?INV:Customer:Prompt),TRN
                           ENTRY(@n-14),AT(61,34,64,10),USE(INV:Customer),RIGHT(1)
                           PROMPT('Date:'),AT(8,48),USE(?INV:Date:Prompt),TRN
                           ENTRY(@d6),AT(61,48,104,10),USE(INV:Date),RIGHT(1)
                           CHECK('Paid'),AT(61,62,70,8),USE(INV:Paid)
                           OPTION('Terms'),AT(61,74,50,48),USE(INV:Terms),BOXED,TRN
                             RADIO('COD'),AT(65,84),USE(?INV:Terms:Radio1),TRN,VALUE('0')
                             RADIO('7 Days'),AT(65,96),USE(?INV:Terms:Radio2),TRN,VALUE('1')
                             RADIO('30 Days'),AT(65,108),USE(?INV:Terms:Radio3),TRN,VALUE('2')
                           END
                         END
                         TAB('Line Items'),USE(?TAB1)
                           LIST,AT(11,24,240,92),USE(?List),RIGHT(1),HVSCROLL,FORMAT('20L(2)|M~ID~L(1)@n-14@80L(2)' & |
  '|M~Product~L(0)@s40@44L(2)|M~Price~D(12)@n-10.2@60L(2)|M~Quantity~C(1)@n-14@'),FROM(Queue:Browse), |
  IMM
                           BUTTON('&Insert'),AT(95,120,50,14),USE(?Insert),LEFT,ICON('add.ico')
                           BUTTON('&Change'),AT(149,120,50,14),USE(?Change),LEFT,ICON('change.ico')
                           BUTTON('&Delete'),AT(202,120,50,14),USE(?Delete),LEFT,ICON('delete.ico')
                         END
                       END
                       BUTTON('&OK'),AT(157,147,50,14),USE(?OK),LEFT,ICON('ok.ico'),DEFAULT,MSG('Accept data a' & |
  'nd close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(211,147,50,14),USE(?Cancel),LEFT,ICON('cancel.ico'),MSG('Cancel operation'), |
  TIP('Cancel operation')
                     END

BRW5::LastSortOrder       BYTE
BRW5::SortHeader  CLASS(SortHeaderClassType) !Declare SortHeader Class
QueueResorted          PROCEDURE(STRING pString),VIRTUAL
                  END
ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
SetAlerts              PROCEDURE(),DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW5                 CLASS(BrowseClass)                    ! Browse using ?List
Q                      &Queue:Browse                  !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
SetSort                PROCEDURE(BYTE NewOrder,BYTE Force),BYTE,PROC,DERIVED
                     END

BRW5::Sort0:Locator  StepLocatorClass                      ! Default Locator
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
  GlobalErrors.SetProcedureName('UpdateInvoice')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?INV:ID:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(INV:Record,History::INV:Record)
  SELF.AddHistoryField(?INV:ID,1)
  SELF.AddHistoryField(?INV:Customer,2)
  SELF.AddHistoryField(?INV:Date,3)
  SELF.AddHistoryField(?INV:Paid,4)
  SELF.AddHistoryField(?INV:Terms,5)
  SELF.AddUpdateFile(Access:Invoice)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Invoice.SetOpenRelated()
  Relate:Invoice.Open                                      ! File Invoice used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Invoice
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
  BRW5.Init(?List,Queue:Browse.ViewPosition,BRW5::View:Browse,Queue:Browse,Relate:LineItems,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?INV:ID{PROP:ReadOnly} = True
    ?INV:Customer{PROP:ReadOnly} = True
    ?INV:Date{PROP:ReadOnly} = True
    DISABLE(?Insert)
    DISABLE(?Change)
    DISABLE(?Delete)
  END
  BRW5.Q &= Queue:Browse
  BRW5.FileLoaded = 1                                      ! This is a 'file loaded' browse
  BRW5.AddSortOrder(,LIN:InvKey)                           ! Add the sort order for LIN:InvKey for sort order 1
  BRW5.AddRange(LIN:InvoiceNumber,Relate:LineItems,Relate:Invoice) ! Add file relationship range limit for sort order 1
  BRW5.AddLocator(BRW5::Sort0:Locator)                     ! Browse has a locator for sort order 1
  BRW5::Sort0:Locator.Init(,LIN:ID,1,BRW5)                 ! Initialize the browse locator using  using key: LIN:InvKey , LIN:ID
  BRW5.AddField(LIN:ID,BRW5.Q.LIN:ID)                      ! Field LIN:ID is a hot field or requires assignment from browse
  BRW5.AddField(PRO:Name,BRW5.Q.PRO:Name)                  ! Field PRO:Name is a hot field or requires assignment from browse
  BRW5.AddField(LIN:Price,BRW5.Q.LIN:Price)                ! Field LIN:Price is a hot field or requires assignment from browse
  BRW5.AddField(LIN:Quantity,BRW5.Q.LIN:Quantity)          ! Field LIN:Quantity is a hot field or requires assignment from browse
  BRW5.AddField(LIN:InvoiceNumber,BRW5.Q.LIN:InvoiceNumber) ! Field LIN:InvoiceNumber is a hot field or requires assignment from browse
  BRW5.AddField(PRO:ID,BRW5.Q.PRO:ID)                      ! Field PRO:ID is a hot field or requires assignment from browse
  INIMgr.Fetch('UpdateInvoice',QuickWindow)                ! Restore window settings from non-volatile store
  BRW5.AskProcedure = 1                                    ! Will call: UpdateLineItems
  BRW5.AddToolbarTarget(Toolbar)                           ! Browse accepts toolbar control
  SELF.SetAlerts()
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW5::SortHeader.Init(Queue:Browse,?List,'','',BRW5::View:Browse)
  BRW5::SortHeader.UseSortColors = False
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Invoice.Close
  !Kill the Sort Header
  BRW5::SortHeader.Kill()
  END
  IF SELF.Opened
    INIMgr.Update('UpdateInvoice',QuickWindow)             ! Save window data to non-volatile store
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


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    UpdateLineItems
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


ThisWindow.SetAlerts PROCEDURE

  CODE
  PARENT.SetAlerts
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW5::SortHeader.SetAlerts()


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


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  !Take Sort Headers Events
  IF BRW5::SortHeader.TakeEvents()
     RETURN Level:Notify
  END
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


BRW5.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert
    SELF.ChangeControl=?Change
    SELF.DeleteControl=?Delete
  END


BRW5.SetSort PROCEDURE(BYTE NewOrder,BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.SetSort(NewOrder,Force)
  IF BRW5::LastSortOrder<>NewOrder THEN
     BRW5::SortHeader.ClearSort()
  END
  BRW5::LastSortOrder=NewOrder
  RETURN ReturnValue

BRW5::SortHeader.QueueResorted       PROCEDURE(STRING pString)
  CODE
    IF pString = ''
       BRW5.RestoreSort()
       BRW5.ResetSort(True)
    ELSE
       BRW5.ReplaceSort(pString,BRW5::Sort0:Locator)
       BRW5.SetLocatorFromSort()
    END
