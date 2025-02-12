

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('DEMO003.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('DEMO002.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Product file
!!! </summary>
BrowseProduct PROCEDURE 

CurrentTab           STRING(80)                            !
BRW1::View:Browse    VIEW(Product)
                       PROJECT(PRO:ID)
                       PROJECT(PRO:Name)
                       PROJECT(PRO:RRP)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
PRO:ID                 LIKE(PRO:ID)                   !List box control field - type derived from field
PRO:Name               LIKE(PRO:Name)                 !List box control field - type derived from field
PRO:RRP                LIKE(PRO:RRP)                  !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Product file'),AT(,,220,199),FONT('Segoe UI',10,COLOR:Black,FONT:regular), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseProduct'),SYSTEM
                       LIST,AT(8,30,204,123),USE(?Browse:1),HVSCROLL,FORMAT('64R(2)|M~ID~C(0)@n-14@80L(2)|M~Na' & |
  'me~L(2)@s40@48D(24)|M~RRP~C(0)@n-10.2@'),FROM(Queue:Browse:1),IMM,MSG('Browsing the ' & |
  'Product file')
                       BUTTON('&Select'),AT(7,157,43,14),USE(?Select),LEFT,ICON('Ok.Ico')
                       BUTTON('&Insert'),AT(54,157,50,14),USE(?Insert:2),LEFT,ICON('add.ico'),MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(108,157,50,14),USE(?Change:2),LEFT,ICON('change.ico'),DEFAULT,MSG('Change the Record'), |
  TIP('Change the Record')
                       BUTTON('&Delete'),AT(162,157,50,14),USE(?Delete:2),LEFT,ICON('delete.ico'),MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,212,172),USE(?CurrentTab)
                         TAB('By Key'),USE(?Tab:2)
                         END
                         TAB('By Name'),USE(?Tab:3)
                         END
                       END
                       BUTTON('&Close'),AT(166,180,50,14),USE(?Close),LEFT,ICON('close.ico'),MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort0:StepClass StepLongClass                        ! Default Step Manager
BRW1::Sort1:StepClass StepStringClass                      ! Conditional Step Manager - CHOICE(?CurrentTab) = 2
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
  GlobalErrors.SetProcedureName('BrowseProduct')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:Product.Open                                      ! File Product used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Product,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1::Sort1:StepClass.Init(+ScrollSort:AllowAlpha,ScrollBy:Runtime) ! Moveable thumb based upon PRO:Name for sort order 1
  BRW1.AddSortOrder(BRW1::Sort1:StepClass,PRO:NameKey)     ! Add the sort order for PRO:NameKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,PRO:Name,1,BRW1)               ! Initialize the browse locator using  using key: PRO:NameKey , PRO:Name
  BRW1::Sort0:StepClass.Init(+ScrollSort:AllowAlpha)       ! Moveable thumb based upon PRO:ID for sort order 2
  BRW1.AddSortOrder(BRW1::Sort0:StepClass,PRO:Key)         ! Add the sort order for PRO:Key for sort order 2
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,PRO:ID,1,BRW1)                 ! Initialize the browse locator using  using key: PRO:Key , PRO:ID
  BRW1.AddField(PRO:ID,BRW1.Q.PRO:ID)                      ! Field PRO:ID is a hot field or requires assignment from browse
  BRW1.AddField(PRO:Name,BRW1.Q.PRO:Name)                  ! Field PRO:Name is a hot field or requires assignment from browse
  BRW1.AddField(PRO:RRP,BRW1.Q.PRO:RRP)                    ! Field PRO:RRP is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseProduct',QuickWindow)                ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateProduct
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Product.Close
  END
  IF SELF.Opened
    INIMgr.Update('BrowseProduct',QuickWindow)             ! Save window data to non-volatile store
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
    UpdateProduct
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  SELF.SelectControl = ?Select
  SELF.HideSelect = 1                                      ! Hide the select button when disabled
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:2
    SELF.ChangeControl=?Change:2
    SELF.DeleteControl=?Delete:2
  END


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CHOICE(?CurrentTab) = 2
    RETURN SELF.SetSort(1,Force)
  ELSE
    RETURN SELF.SetSort(2,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

