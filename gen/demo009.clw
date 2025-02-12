

   MEMBER('demo.clw')                                      ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('DEMO009.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the EmailLog file
!!! </summary>
BrowseEmailLog PROCEDURE 

parms        group(EmailParametersGroup).
CurrentTab           STRING(80)                            !
loc:Blank            STRING(1)                             !
BRW1::View:Browse    VIEW(EmailLog)
                       PROJECT(emLog:User)
                       PROJECT(emLog:Date)
                       PROJECT(emLog:Time)
                       PROJECT(emLog:SendDate)
                       PROJECT(emLog:SendTime)
                       PROJECT(emLog:ToEmail)
                       PROJECT(emLog:Subject)
                       PROJECT(emLog:FromEmail)
                       PROJECT(emLog:CC)
                       PROJECT(emLog:BCC)
                       PROJECT(emLog:Attachment)
                       PROJECT(emLog:MessageText)
                       PROJECT(emLog:Guid)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
loc:Blank              LIKE(loc:Blank)                !List box control field - type derived from local data
loc:Blank_Icon         LONG                           !Entry's icon ID
loc:Blank_Style        LONG                           !Field style
emLog:User             LIKE(emLog:User)               !List box control field - type derived from field
emLog:User_Style       LONG                           !Field style
emLog:Date             LIKE(emLog:Date)               !List box control field - type derived from field
emLog:Date_Style       LONG                           !Field style
emLog:Time             LIKE(emLog:Time)               !List box control field - type derived from field
emLog:Time_Style       LONG                           !Field style
emLog:SendDate         LIKE(emLog:SendDate)           !List box control field - type derived from field
emLog:SendDate_Style   LONG                           !Field style
emLog:SendTime         LIKE(emLog:SendTime)           !List box control field - type derived from field
emLog:SendTime_Style   LONG                           !Field style
emLog:ToEmail          LIKE(emLog:ToEmail)            !List box control field - type derived from field
emLog:ToEmail_Style    LONG                           !Field style
emLog:Subject          LIKE(emLog:Subject)            !List box control field - type derived from field
emLog:Subject_Style    LONG                           !Field style
emLog:FromEmail        LIKE(emLog:FromEmail)          !List box control field - type derived from field
emLog:FromEmail_Style  LONG                           !Field style
emLog:CC               LIKE(emLog:CC)                 !List box control field - type derived from field
emLog:CC_Style         LONG                           !Field style
emLog:BCC              LIKE(emLog:BCC)                !List box control field - type derived from field
emLog:BCC_Style        LONG                           !Field style
emLog:Attachment       LIKE(emLog:Attachment)         !List box control field - type derived from field
emLog:Attachment_Style LONG                           !Field style
emLog:MessageText      STRING(SIZE(emLog:MessageText)) !Browse hot field - STRING defined to hold MEMO's contents
emLog:Guid             LIKE(emLog:Guid)               !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Email Log'),AT(,,447,206),FONT('Segoe UI',10,,FONT:regular,CHARSET:DEFAULT),RESIZE, |
  CENTER,GRAY,IMM,MDI,HLP('BrowseEmailLog'),SYSTEM
                       LIST,AT(8,9,431,113),USE(?Browse:1),HVSCROLL,FORMAT('12L(2)JY@s1@80L(2)|MY~User~@s255@[' & |
  '40L(2)|MY~Date~C(0)@d1@40L(2)|MY~Time~C(0)@t4@]|~Created~[40L(2)|MY~Date~C(0)@d1@40L' & |
  '(2)|MY~Time~C(0)@t4@]|~Sent~80L(2)|MY~To~@s255@80L(2)|MY~Subject~@s255@80L(2)|MY~Fro' & |
  'm~@s255@1020L(2)|MY~CC~L(0)@s255@1020L(2)|MY~BCC~L(0)@s255@1020L(2)|MY~Attachment~L(0)@s255@'), |
  FROM(Queue:Browse:1),IMM,MSG('Browsing the EmailLog file')
                       BUTTON('&Close'),AT(389,186,50,14),USE(?Close),LEFT,ICON('close.ico'),MSG('Close Window'), |
  TIP('Close Window')
                       TEXT,AT(7,132,431,44),USE(emLog:MessageText),HVSCROLL
                       BUTTON('Resend'),AT(335,186,50,14),USE(?ResendButton),LEFT,ICON('email.ico')
                     END

BRW1::LastSortOrder       BYTE
BRW1::SortHeader  CLASS(SortHeaderClassType) !Declare SortHeader Class
QueueResorted          PROCEDURE(STRING pString),VIRTUAL
ValidField             PROCEDURE(STRING pColumnName),BYTE,VIRTUAL
GetSortingColumnString PROCEDURE(STRING pSign,STRING pColumnName,STRING pColumnPicture),STRING,VIRTUAL
                  END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
SetAlerts              PROCEDURE(),DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
SetQueueRecord         PROCEDURE(),DERIVED
SetSort                PROCEDURE(BYTE NewOrder,BYTE Force),BYTE,PROC,DERIVED
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
  !------------------------------------
  !Style for ?Browse:1
  !------------------------------------
  ?Browse:1{PROPSTYLE:FontName, 1}      = 'Segoe UI'
  ?Browse:1{PROPSTYLE:FontSize, 1}      = 10
  ?Browse:1{PROPSTYLE:FontStyle, 1}     = 400
  ?Browse:1{PROPSTYLE:TextColor, 1}     = -1
  ?Browse:1{PROPSTYLE:BackColor, 1}     = 12632319
  ?Browse:1{PROPSTYLE:TextSelected, 1}  = -1
  ?Browse:1{PROPSTYLE:BackSelected, 1}  = 8421631
  !------------------------------------
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('BrowseEmailLog')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  BIND('loc:Blank',loc:Blank)                              ! Added by: BrowseBox(ABC)
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:EmailLog.Open                                     ! File EmailLog used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:EmailLog,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1::Sort0:StepClass.Init(+ScrollSort:AllowAlpha,ScrollBy:Runtime) ! Moveable thumb based upon emLog:Guid for sort order 1
  BRW1.AddSortOrder(BRW1::Sort0:StepClass,emLog:KeyGuid)   ! Add the sort order for emLog:KeyGuid for sort order 1
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort0:Locator.Init(,emLog:Guid,1,BRW1)             ! Initialize the browse locator using  using key: emLog:KeyGuid , emLog:Guid
  ?Browse:1{PROP:IconList,1} = '~Attachment.ico'
  BRW1.AddField(loc:Blank,BRW1.Q.loc:Blank)                ! Field loc:Blank is a hot field or requires assignment from browse
  BRW1.AddField(emLog:User,BRW1.Q.emLog:User)              ! Field emLog:User is a hot field or requires assignment from browse
  BRW1.AddField(emLog:Date,BRW1.Q.emLog:Date)              ! Field emLog:Date is a hot field or requires assignment from browse
  BRW1.AddField(emLog:Time,BRW1.Q.emLog:Time)              ! Field emLog:Time is a hot field or requires assignment from browse
  BRW1.AddField(emLog:SendDate,BRW1.Q.emLog:SendDate)      ! Field emLog:SendDate is a hot field or requires assignment from browse
  BRW1.AddField(emLog:SendTime,BRW1.Q.emLog:SendTime)      ! Field emLog:SendTime is a hot field or requires assignment from browse
  BRW1.AddField(emLog:ToEmail,BRW1.Q.emLog:ToEmail)        ! Field emLog:ToEmail is a hot field or requires assignment from browse
  BRW1.AddField(emLog:Subject,BRW1.Q.emLog:Subject)        ! Field emLog:Subject is a hot field or requires assignment from browse
  BRW1.AddField(emLog:FromEmail,BRW1.Q.emLog:FromEmail)    ! Field emLog:FromEmail is a hot field or requires assignment from browse
  BRW1.AddField(emLog:CC,BRW1.Q.emLog:CC)                  ! Field emLog:CC is a hot field or requires assignment from browse
  BRW1.AddField(emLog:BCC,BRW1.Q.emLog:BCC)                ! Field emLog:BCC is a hot field or requires assignment from browse
  BRW1.AddField(emLog:Attachment,BRW1.Q.emLog:Attachment)  ! Field emLog:Attachment is a hot field or requires assignment from browse
  BRW1.AddField(emLog:MessageText,BRW1.Q.emLog:MessageText) ! Field emLog:MessageText is a hot field or requires assignment from browse
  BRW1.AddField(emLog:Guid,BRW1.Q.emLog:Guid)              ! Field emLog:Guid is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseEmailLog',QuickWindow)               ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.Init(Queue:Browse:1,?Browse:1,'','',BRW1::View:Browse)
  BRW1::SortHeader.UseSortColors = False
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:EmailLog.Close
  !Kill the Sort Header
  BRW1::SortHeader.Kill()
  END
  IF SELF.Opened
    INIMgr.Update('BrowseEmailLog',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.SetAlerts PROCEDURE

  CODE
  PARENT.SetAlerts
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.SetAlerts()


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
    OF ?ResendButton
      ThisWindow.Update()
            clear(parms)
            parms.pEmailTo = emLog:ToEmail
            parms.pEmailCC = emLog:CC
            parms.pEmailBCC = emLog:BCC
            parms.pEmailFileList = emLog:Attachment 
            parms.pEmailEmbedList = emLog:EmbedList      
            parms.pEmailSubject = emLog:Subject
            parms.pEmailMessageText = emLog:MessageText
            parms.pEmailMessageHTML = emLog:MessageHTML
            parms.pHide = true
            If SendEmail(parms) = 0
              MESSAGE('Mail Resent','Information')
            Else  
              MESSAGE('Mail Failed','Error')
            End   
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
  IF BRW1::SortHeader.TakeEvents()
     RETURN Level:Notify
  END
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


BRW1.SetQueueRecord PROCEDURE

  CODE
  PARENT.SetQueueRecord
  
  IF (emLog:SendDate = 0)
    SELF.Q.loc:Blank_Style = 1 ! 
    SELF.Q.emLog:User_Style = 1 ! 
    SELF.Q.emLog:Date_Style = 1 ! 
    SELF.Q.emLog:Time_Style = 1 ! 
    SELF.Q.emLog:SendDate_Style = 1 ! 
    SELF.Q.emLog:SendTime_Style = 1 ! 
    SELF.Q.emLog:ToEmail_Style = 1 ! 
    SELF.Q.emLog:Subject_Style = 1 ! 
    SELF.Q.emLog:FromEmail_Style = 1 ! 
    SELF.Q.emLog:CC_Style = 1 ! 
    SELF.Q.emLog:BCC_Style = 1 ! 
    SELF.Q.emLog:Attachment_Style = 1 ! 
  ELSE
    SELF.Q.loc:Blank_Style = 0 ! 
    SELF.Q.emLog:User_Style = 0 ! 
    SELF.Q.emLog:Date_Style = 0 ! 
    SELF.Q.emLog:Time_Style = 0 ! 
    SELF.Q.emLog:SendDate_Style = 0 ! 
    SELF.Q.emLog:SendTime_Style = 0 ! 
    SELF.Q.emLog:ToEmail_Style = 0 ! 
    SELF.Q.emLog:Subject_Style = 0 ! 
    SELF.Q.emLog:FromEmail_Style = 0 ! 
    SELF.Q.emLog:CC_Style = 0 ! 
    SELF.Q.emLog:BCC_Style = 0 ! 
    SELF.Q.emLog:Attachment_Style = 0 ! 
  END
  IF (emLog:Attachment <> '')
    SELF.Q.loc:Blank_Icon = 1                              ! Set icon from icon list
  ELSE
    SELF.Q.loc:Blank_Icon = 0
  END


BRW1.SetSort PROCEDURE(BYTE NewOrder,BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.SetSort(NewOrder,Force)
  IF BRW1::LastSortOrder<>NewOrder THEN
     BRW1::SortHeader.ClearSort()
  END
  BRW1::LastSortOrder=NewOrder
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

BRW1::SortHeader.QueueResorted       PROCEDURE(STRING pString)
  CODE
    IF pString = ''
       BRW1.RestoreSort()
       BRW1.ResetSort(True)
    ELSE
       BRW1.ReplaceSort(pString,BRW1::Sort0:Locator)
       BRW1.SetLocatorFromSort()
    END


BRW1::SortHeader.ValidField             PROCEDURE(STRING pColumnName)
 CODE
    CASE(UPPER(pColumnName))
    OF 'EMLOG:DATE'
       RETURN True
    OF 'EMLOG:TIME'
       RETURN True
    END
    RETURN PARENT.ValidField(pColumnName)


BRW1::SortHeader.GetSortingColumnString PROCEDURE(STRING pSign,STRING pColumnName,STRING pColumnPicture)
 CODE
    CASE(UPPER(pColumnName))
    OF 'EMLOG:DATE'
       RETURN ''&CHOOSE(pSign='+','+','-')&'UPPER(emLog:Date),'&CHOOSE(pSign='+','+','-')&'UPPER(emLog:Time)'
    OF 'EMLOG:TIME'
       RETURN ''&CHOOSE(pSign='+','+','-')&'UPPER(emLog:Date),'&CHOOSE(pSign='+','+','-')&'UPPER(emLog:Time)'
    END
    RETURN PARENT.GetSortingColumnString(pSign,pColumnName,pColumnPicture)
