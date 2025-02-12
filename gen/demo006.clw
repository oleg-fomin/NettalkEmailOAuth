

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('DEMO006.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('DEMO005.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Invoice file
!!! </summary>
BrowseInvoice PROCEDURE 

parms group(EmailParametersGroup).
CurrentTab           STRING(80)                            !
BRW1::View:Browse    VIEW(Invoice)
                       PROJECT(INV:ID)
                       PROJECT(INV:Date)
                       PROJECT(INV:Paid)
                       PROJECT(INV:Terms)
                       PROJECT(INV:Customer)
                       JOIN(CUS:Key,INV:Customer)
                         PROJECT(CUS:Name)
                         PROJECT(CUS:Email)
                         PROJECT(CUS:ID)
                       END
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
INV:ID                 LIKE(INV:ID)                   !List box control field - type derived from field
CUS:Name               LIKE(CUS:Name)                 !List box control field - type derived from field
INV:Date               LIKE(INV:Date)                 !List box control field - type derived from field
INV:Paid               LIKE(INV:Paid)                 !List box control field - type derived from field
INV:Terms              LIKE(INV:Terms)                !List box control field - type derived from field
CUS:Email              LIKE(CUS:Email)                !Browse hot field - type derived from field
CUS:ID                 LIKE(CUS:ID)                   !Related join file key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Invoice file'),AT(,,324,192),FONT('Segoe UI',10,COLOR:Black,FONT:regular), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseInvoice'),SYSTEM
                       LIST,AT(8,10,307,143),USE(?Browse:1),HVSCROLL,FORMAT('64R(2)|M~ID~C(0)@n-14@80R(2)|M~Cu' & |
  'stomer~C(0)@s20@80R(2)|M~Date~C(0)@d6@20R(2)|M~Paid~C(0)@n3@64R(2)|M~Terms~C(0)@n-14@'), |
  FROM(Queue:Browse:1),IMM,MSG('Browsing the Invoice file')
                       BUTTON('&Insert'),AT(157,156,50,14),USE(?Insert:2),LEFT,ICON('add.ico'),MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(212,156,50,14),USE(?Change:2),LEFT,ICON('change.ico'),DEFAULT,MSG('Change the Record'), |
  TIP('Change the Record')
                       BUTTON('&Delete'),AT(265,156,50,14),USE(?Delete:2),LEFT,ICON('delete.ico'),MSG('Delete the Record'), |
  TIP('Delete the Record')
                       BUTTON('&Close'),AT(265,173,50,14),USE(?Close),LEFT,ICON('close.ico'),MSG('Close Window'), |
  TIP('Close Window')
                       BUTTON('Email'),AT(103,156,50,14),USE(?EmailButton),LEFT,ICON('email.ico')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort0:StepClass StepLongClass                        ! Default Step Manager
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('BrowseInvoice')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:Customer.Open                                     ! File Customer used by this procedure, so make sure it's RelationManager is open
  Relate:Invoice.SetOpenRelated()
  Relate:Invoice.Open                                      ! File Invoice used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Invoice,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1::Sort0:StepClass.Init(+ScrollSort:AllowAlpha)       ! Moveable thumb based upon INV:ID for sort order 1
  BRW1.AddSortOrder(BRW1::Sort0:StepClass,INV:Key)         ! Add the sort order for INV:Key for sort order 1
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort0:Locator.Init(,INV:ID,1,BRW1)                 ! Initialize the browse locator using  using key: INV:Key , INV:ID
  BRW1.AddField(INV:ID,BRW1.Q.INV:ID)                      ! Field INV:ID is a hot field or requires assignment from browse
  BRW1.AddField(CUS:Name,BRW1.Q.CUS:Name)                  ! Field CUS:Name is a hot field or requires assignment from browse
  BRW1.AddField(INV:Date,BRW1.Q.INV:Date)                  ! Field INV:Date is a hot field or requires assignment from browse
  BRW1.AddField(INV:Paid,BRW1.Q.INV:Paid)                  ! Field INV:Paid is a hot field or requires assignment from browse
  BRW1.AddField(INV:Terms,BRW1.Q.INV:Terms)                ! Field INV:Terms is a hot field or requires assignment from browse
  BRW1.AddField(CUS:Email,BRW1.Q.CUS:Email)                ! Field CUS:Email is a hot field or requires assignment from browse
  BRW1.AddField(CUS:ID,BRW1.Q.CUS:ID)                      ! Field CUS:ID is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseInvoice',QuickWindow)                ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateInvoice
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Customer.Close
    Relate:Invoice.Close
  END
  IF SELF.Opened
    INIMgr.Update('BrowseInvoice',QuickWindow)             ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    UpdateInvoice
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
    OF ?EmailButton
      ThisWindow.Update()
      clear(parms)
      parms.pEmailTo = CUS:Email
      parms.pEmailFrom = glo:UserEmail
      parms.pEmailSubject = 'Invoice ' & INV:ID
      parms.pEmailCC = ''
      parms.pEmailBCC = ''
      parms.pEmailFileList = '' ! should be the name of some PDF file.
      parms.pEmailEmbedList = ''
      parms.pEmailMessageText = 'Please find the invoice attached'
      parms.pEmailMessageHTML = '<html><body>Please find the invoice attached</body></html>'
      parms.pHide = false
      SendEmail(Parms)
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:2
    SELF.ChangeControl=?Change:2
    SELF.DeleteControl=?Delete:2
  END


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

