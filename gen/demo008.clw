

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('DEMO008.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('DEMO007.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Customer file
!!! </summary>
BrowseCustomer PROCEDURE 

CurrentTab           STRING(80)                            !
BRW1::View:Browse    VIEW(Customer)
                       PROJECT(CUS:ID)
                       PROJECT(CUS:Name)
                       PROJECT(CUS:Email)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
CUS:ID                 LIKE(CUS:ID)                   !List box control field - type derived from field
CUS:Name               LIKE(CUS:Name)                 !List box control field - type derived from field
CUS:Email              LIKE(CUS:Email)                !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Customer file'),AT(,,280,199),FONT('Segoe UI',10,COLOR:Black,FONT:regular), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseCustomer'),SYSTEM
                       LIST,AT(8,8,264,144),USE(?Browse:1),HVSCROLL,FORMAT('54R(2)|M~ID~C(0)@n-14@80L(2)|M~Nam' & |
  'e~@s20@100L(2)|M~Email~C(0)@s255@'),FROM(Queue:Browse:1),IMM,MSG('Browsing the Customer file')
                       BUTTON('&Insert'),AT(114,157,50,15),USE(?Insert:2),LEFT,ICON('add.ico'),MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(168,157,50,15),USE(?Change:2),LEFT,ICON('change.ico'),DEFAULT,MSG('Change the Record'), |
  TIP('Change the Record')
                       BUTTON('&Delete'),AT(222,157,50,15),USE(?Delete:2),LEFT,ICON('delete.ico'),MSG('Delete the Record'), |
  TIP('Delete the Record')
                       BUTTON('&Close'),AT(226,180,50,15),USE(?Close),LEFT,ICON('close.ico'),MSG('Close Window'), |
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
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort0:StepClass StepStringClass                      ! Default Step Manager
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
  GlobalErrors.SetProcedureName('BrowseCustomer')
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
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Customer,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1::Sort0:StepClass.Init(+ScrollSort:AllowAlpha,ScrollBy:Runtime) ! Moveable thumb based upon CUS:Name for sort order 1
  BRW1.AddSortOrder(BRW1::Sort0:StepClass,CUS:NameKey)     ! Add the sort order for CUS:NameKey for sort order 1
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort0:Locator.Init(,CUS:Name,1,BRW1)               ! Initialize the browse locator using  using key: CUS:NameKey , CUS:Name
  BRW1.AddField(CUS:ID,BRW1.Q.CUS:ID)                      ! Field CUS:ID is a hot field or requires assignment from browse
  BRW1.AddField(CUS:Name,BRW1.Q.CUS:Name)                  ! Field CUS:Name is a hot field or requires assignment from browse
  BRW1.AddField(CUS:Email,BRW1.Q.CUS:Email)                ! Field CUS:Email is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseCustomer',QuickWindow)               ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateCustomer
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
    INIMgr.Update('BrowseCustomer',QuickWindow)            ! Save window data to non-volatile store
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
    UpdateCustomer
    ReturnValue = GlobalResponse
  END
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

