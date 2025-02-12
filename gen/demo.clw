   PROGRAM


NetTalk:TemplateVersion equate('14.29')
ActivateNetTalk   EQUATE(1)
  include('NetAll.inc'),once
  include('NetMap.inc'),once
  include('NetTalk.inc'),once
  include('NetSimp.inc'),once
  include('NetFtp.inc'),once
  include('NetHttp.inc'),once
  include('NetWww.inc'),once
  include('NetSync.inc'),once
  include('NetWeb.inc'),once
  include('NetWebSessions.inc'),once
  include('NetWebSocketClient.inc'),once
  include('NetWebSocketServer.inc'),once
  include('NetWebM.inc'),once
  include('NetWSDL.inc'),once
  include('NetEmail.inc'),once
  include('NetFile.inc'),once
  include('NetWebSms.inc'),once
  Include('NetOauth.inc'),once
  Include('NetLDAP.inc'),once
  Include('NetMaps.inc'),once
  Include('NetDrive.inc'),once
  Include('NetSms.inc'),once
  Include('NetDns.inc'),once
StringTheory:TemplateVersion equate('3.70')
jFiles:TemplateVersion equate('3.09')
Reflection:TemplateVersion equate('1.30')

   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
  include('cwsynchc.inc'),once  ! added by NetTalk
  include('StringTheory.Inc'),ONCE
   include('jFiles.inc'),ONCE
  include('Reflection.Inc'),ONCE

   MAP
     MODULE('DEMO_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('DEMO001.CLW')
Main                   PROCEDURE   !
     END
     MODULE('DEMO009.CLW')
BrowseEmailLog         PROCEDURE   !Browse the EmailLog file
     END
     MODULE('DEMO010.CLW')
UpdateEmailSettings    PROCEDURE   !Form EmailSettings
     END
     MODULE('DEMO011.CLW')
SendEmail              FUNCTION(EmailParametersGroup pEmail),Long,Proc   !
     END
   END

  include('StringTheory.Inc'),ONCE
Glo:UserEmail        STRING(255)
Glo:UserName         STRING(255)
SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
Invoice              FILE,DRIVER('TOPSPEED'),PRE(INV),BINDABLE,CREATE,THREAD !                    
Key                      KEY(INV:ID),NOCASE,OPT,PRIMARY    !                    
CustomerKey              KEY(INV:Customer),DUP,NOCASE,OPT  !                    
Record                   RECORD,PRE()
ID                          LONG                           !                    
Customer                    LONG                           !                    
Date                        LONG                           !                    
Paid                        BYTE                           !                    
Terms                       LONG                           !                    
                         END
                     END                       

Product              FILE,DRIVER('TOPSPEED'),PRE(PRO),BINDABLE,CREATE,THREAD !                    
Key                      KEY(PRO:ID),NOCASE,OPT,PRIMARY    !                    
NameKey                  KEY(PRO:Name),DUP,NOCASE,OPT      !                    
Record                   RECORD,PRE()
ID                          LONG                           !                    
Name                        STRING(40)                     !                    
RRP                         DECIMAL(7,2)                   !                    
                         END
                     END                       

LineItems            FILE,DRIVER('TOPSPEED'),PRE(LIN),BINDABLE,CREATE,THREAD !                    
Key                      KEY(LIN:ID),NOCASE,OPT,PRIMARY    !                    
ProductKey               KEY(LIN:Product),DUP,NOCASE,OPT   !                    
InvKey                   KEY(LIN:InvoiceNumber,LIN:ID),DUP,NOCASE,OPT !                    
Record                   RECORD,PRE()
ID                          LONG                           !                    
InvoiceNumber               LONG                           !                    
Product                     LONG                           !                    
Price                       DECIMAL(7,2)                   !                    
Quantity                    LONG                           !                    
                         END
                     END                       

Customer             FILE,DRIVER('TOPSPEED'),PRE(CUS),BINDABLE,CREATE,THREAD !                    
NameKey                  KEY(CUS:Name),DUP,NOCASE,OPT      !                    
Key                      KEY(CUS:ID),NOCASE,OPT,PRIMARY    !                    
Record                   RECORD,PRE()
ID                          LONG                           !                    
Name                        STRING(20)                     !                    
Email                       STRING(255)                    !                    
                         END
                     END                       

EmailLog             FILE,DRIVER('TOPSPEED'),PRE(emLog),CREATE,BINDABLE,THREAD !                    
KeyGuid                  KEY(emLog:Guid),NOCASE,PRIMARY    !                    
KeyTo                    KEY(emLog:ToEmail,emLog:Date,emLog:Time),DUP,NOCASE !                    
KeyFrom                  KEY(emLog:FromEmail,emLog:Date,emLog:Time),DUP,NOCASE !                    
KeyDate                  KEY(emLog:Date,emLog:Time),DUP,NOCASE !                    
KeyUser                  KEY(emLog:User,emLog:Date,emLog:Time),DUP,NOCASE !                    
KeyStatus                KEY(emLog:Status),DUP,NOCASE      !                    
MessageText                 MEMO(64000)                    !                    
MessageHTML                 MEMO(64000)                    !                    
Record                   RECORD,PRE()
Guid                        STRING(16)                     !                    
User                        STRING(255)                    !                    
Date                        LONG                           !                    
Time                        LONG                           !                    
SendDate                    LONG                           !                    
SendTime                    LONG                           !                    
ToEmail                     STRING(255)                    !                    
FromEmail                   STRING(255)                    !                    
Subject                     STRING(255)                    !                    
CC                          STRING(255)                    !                    
BCC                         STRING(255)                    !                    
Attachment                  STRING(1024)                   !                    
EmbedList                   STRING(1024)                   !                    
Status                      LONG                           !                    
                         END
                     END                       

EmailSettings        FILE,DRIVER('TOPSPEED'),PRE(emSet),CREATE,BINDABLE,THREAD !                    
KeyGuid                  KEY(emSet:Guid),NOCASE,PRIMARY    !                    
Record                   RECORD,PRE()
Guid                        STRING(16)                     !                    
EmailServer                 STRING(255)                    !                    
EmailPort                   LONG                           !                    
AlwaysSSL                   LONG                           !                    
StartTLS                    LONG                           !                    
SSLMethod                   LONG                           !                    
Username                    STRING(255)                    !                    
Password                    STRING(255)                    !                    
FromAddress                 STRING(255)                    !                    
                         END
                     END                       

!endregion

Access:Invoice       &FileManager,THREAD                   ! FileManager for Invoice
Relate:Invoice       &RelationManager,THREAD               ! RelationManager for Invoice
Access:Product       &FileManager,THREAD                   ! FileManager for Product
Relate:Product       &RelationManager,THREAD               ! RelationManager for Product
Access:LineItems     &FileManager,THREAD                   ! FileManager for LineItems
Relate:LineItems     &RelationManager,THREAD               ! RelationManager for LineItems
Access:Customer      &FileManager,THREAD                   ! FileManager for Customer
Relate:Customer      &RelationManager,THREAD               ! RelationManager for Customer
Access:EmailLog      &FileManager,THREAD                   ! FileManager for EmailLog
Relate:EmailLog      &RelationManager,THREAD               ! RelationManager for EmailLog
Access:EmailSettings &FileManager,THREAD                   ! FileManager for EmailSettings
Relate:EmailSettings &RelationManager,THREAD               ! RelationManager for EmailSettings

FuzzyMatcher         FuzzyClass                            ! Global fuzzy matcher
GlobalErrorStatus    ErrorStatusClass,THREAD
GlobalErrors         ErrorClass                            ! Global error manager
INIMgr               INIClass                              ! Global non-volatile storage manager
GlobalRequest        BYTE(0),THREAD                        ! Set when a browse calls a form, to let it know action to perform
GlobalResponse       BYTE(0),THREAD                        ! Set to the response from the form
VCRRequest           LONG(0),THREAD                        ! Set to the request from the VCR buttons

Dictionary           CLASS,THREAD
Construct              PROCEDURE
Destruct               PROCEDURE
                     END


  CODE
  GlobalErrors.Init(GlobalErrorStatus)
  FuzzyMatcher.Init                                        ! Initilaize the browse 'fuzzy matcher'
  FuzzyMatcher.SetOption(MatchOption:NoCase, 1)            ! Configure case matching
  FuzzyMatcher.SetOption(MatchOption:WordOnly, 0)          ! Configure 'word only' matching
  INIMgr.Init('.\demo.INI', NVD_INI)                       ! Configure INIManager to use INI file
  DctInit
                             ! Begin Generated by NetTalk Extension Template
  
    if ~command ('/netnolog') and (command ('/nettalklog') or command ('/nettalklogerrors') or command ('/neterrors') or command ('/netall'))
      NetDebugTrace ('[Nettalk Template] NetTalk Template version 14.29')
      NetDebugTrace ('[Nettalk Template] NetTalk Template using Clarion ' & 10000)
      NetDebugTrace ('[Nettalk Template] NetTalk Object version ' & NETTALK:VERSION )
      NetDebugTrace ('[Nettalk Template] ABC Template Chain')
    end
                             ! End Generated by Extension Template
  Main
  INIMgr.Update
                             ! Begin Generated by NetTalk Extension Template
    NetCloseCallBackWindow() ! Tell NetTalk DLL to shutdown it's WinSock Call Back Window
  
    if ~command ('/netnolog') and (command ('/nettalklog') or command ('/nettalklogerrors') or command ('/neterrors') or command ('/netall'))
      NetDebugTrace ('[Nettalk Template] NetTalk Template version 14.29')
      NetDebugTrace ('[Nettalk Template] NetTalk Template using Clarion ' & 10000)
      NetDebugTrace ('[Nettalk Template] Closing Down NetTalk (Object) version ' & NETTALK:VERSION)
    end
                             ! End Generated by Extension Template
  INIMgr.Kill                                              ! Destroy INI manager
  FuzzyMatcher.Kill                                        ! Destroy fuzzy matcher


Dictionary.Construct PROCEDURE

  CODE
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

