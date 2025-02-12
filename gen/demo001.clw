

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('DEMO001.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('DEMO003.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('DEMO006.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('DEMO008.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Frame
!!! </summary>
Main PROCEDURE 

AppFrame             APPLICATION('Application'),AT(,,505,324),FONT('Segoe UI',10,,FONT:regular),RESIZE,CENTER,ICON('WAFRAME.ICO'), |
  MAX,STATUS(-1,80,120,45),SYSTEM,IMM
                       MENUBAR,USE(?Menubar)
                         MENU('&File'),USE(?FileMenu)
                           ITEM('&Print Setup ...'),USE(?PrintSetup),MSG('Setup printer'),STD(STD:PrintSetup)
                           ITEM,USE(?SEPARATOR1),SEPARATOR
                           ITEM('E&xit'),USE(?Exit),MSG('Exit this application'),STD(STD:Close)
                         END
                         MENU('&Browse'),USE(?BrowseMenu)
                           ITEM('Browse the Invoice file'),USE(?BrowseInvoice),MSG('Browse Invoice')
                           ITEM('Browse the Customer file'),USE(?BrowseCustomer),MSG('Browse Customer')
                           ITEM('Browse the Product file'),USE(?BrowseProduct),MSG('Browse Product')
                         END
                         MENU('Email'),USE(?EmailMenu)
                           ITEM('Settings'),USE(?EmailSettings)
                           ITEM('Log'),USE(?EmailLog)
                         END
                       END
                       TOOLBAR,AT(0,0,505,25),USE(?TOOLBAR1)
                         BUTTON('Invoices'),AT(5,5,45,14),USE(?Button1)
                         BUTTON('Customers'),AT(59,5,45,14),USE(?Button2)
                         BUTTON('Products'),AT(113,5,45,14),USE(?Button3)
                         BUTTON('Email Settings'),AT(210,5),USE(?BUTTON4)
                         BUTTON('Email Log'),AT(279,5),USE(?BUTTON5)
                       END
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------
Menu::Menubar ROUTINE                                      ! Code for menu items on ?Menubar
Menu::FileMenu ROUTINE                                     ! Code for menu items on ?FileMenu
Menu::BrowseMenu ROUTINE                                   ! Code for menu items on ?BrowseMenu
  CASE ACCEPTED()
  OF ?BrowseInvoice
    START(BrowseInvoice, 050000)
  OF ?BrowseCustomer
    START(BrowseCustomer, 050000)
  OF ?BrowseProduct
    START(BrowseProduct, 050000)
  END
Menu::EmailMenu ROUTINE                                    ! Code for menu items on ?EmailMenu
  CASE ACCEPTED()
  OF ?EmailSettings
    START(UpdateEmailSettings, 25000)
  OF ?EmailLog
    START(BrowseEmailLog, 25000)
  END

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = 1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.Open(AppFrame)                                      ! Open window
  Do DefineListboxStyle
  INIMgr.Fetch('Main',AppFrame)                            ! Restore window settings from non-volatile store
  SELF.SetAlerts()
      AppFrame{PROP:TabBarVisible}  = False
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.Opened
    INIMgr.Update('Main',AppFrame)                         ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
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
    CASE ACCEPTED()
    ELSE
      DO Menu::Menubar                                     ! Process menu items on ?Menubar menu
      DO Menu::FileMenu                                    ! Process menu items on ?FileMenu menu
      DO Menu::BrowseMenu                                  ! Process menu items on ?BrowseMenu menu
      DO Menu::EmailMenu                                   ! Process menu items on ?EmailMenu menu
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?Button1
      START(BrowseInvoice, 25000)
    OF ?Button2
      START(BrowseCustomer, 25000)
    OF ?Button3
      START(BrowseProduct, 25000)
    OF ?BUTTON4
      START(UpdateEmailSettings, 25000)
    OF ?BUTTON5
      START(BrowseEmailLog, 25000)
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

