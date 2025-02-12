  MEMBER('demo.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
demo_BC0:DctInit    PROCEDURE
demo_BC0:DctKill    PROCEDURE
demo_BC0:FilesInit  PROCEDURE
  END

Hide:Access:Invoice  CLASS(FileManager),TYPE               ! FileManager for Invoice
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
ValidateFieldServer    PROCEDURE(UNSIGNED Id,BYTE HandleErrors),BYTE,PROC,DERIVED
                     END


Hide:Relate:Invoice  CLASS(RelationManager),TYPE           ! RelationManager for Invoice
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Product  CLASS(FileManager),TYPE               ! FileManager for Product
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Product  CLASS(RelationManager),TYPE           ! RelationManager for Product
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:LineItems CLASS(FileManager),TYPE              ! FileManager for LineItems
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:LineItems CLASS(RelationManager),TYPE          ! RelationManager for LineItems
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Customer CLASS(FileManager),TYPE               ! FileManager for Customer
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Customer CLASS(RelationManager),TYPE           ! RelationManager for Customer
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:EmailLog CLASS(FileManager),TYPE               ! FileManager for EmailLog
BindFields             PROCEDURE(),DERIVED
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:EmailLog CLASS(RelationManager),TYPE           ! RelationManager for EmailLog
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:EmailSettings CLASS(FileManager),TYPE          ! FileManager for EmailSettings
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:EmailSettings CLASS(RelationManager),TYPE      ! RelationManager for EmailSettings
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:Invoice &Hide:Access:Invoice,AUTO,THREAD
_Hide:Relate:Invoice &Hide:Relate:Invoice,AUTO,THREAD
_Hide:Access:Product &Hide:Access:Product,AUTO,THREAD
_Hide:Relate:Product &Hide:Relate:Product,AUTO,THREAD
_Hide:Access:LineItems &Hide:Access:LineItems,AUTO,THREAD
_Hide:Relate:LineItems &Hide:Relate:LineItems,AUTO,THREAD
_Hide:Access:Customer &Hide:Access:Customer,AUTO,THREAD
_Hide:Relate:Customer &Hide:Relate:Customer,AUTO,THREAD
_Hide:Access:EmailLog &Hide:Access:EmailLog,AUTO,THREAD
_Hide:Relate:EmailLog &Hide:Relate:EmailLog,AUTO,THREAD
_Hide:Access:EmailSettings &Hide:Access:EmailSettings,AUTO,THREAD
_Hide:Relate:EmailSettings &Hide:Relate:EmailSettings,AUTO,THREAD


demo_BC0:DctInit PROCEDURE
  CODE
  _Hide:Access:Invoice &= NEW(Hide:Access:Invoice)
  _Hide:Relate:Invoice &= NEW(Hide:Relate:Invoice)
  _Hide:Access:Product &= NEW(Hide:Access:Product)
  _Hide:Relate:Product &= NEW(Hide:Relate:Product)
  _Hide:Access:LineItems &= NEW(Hide:Access:LineItems)
  _Hide:Relate:LineItems &= NEW(Hide:Relate:LineItems)
  _Hide:Access:Customer &= NEW(Hide:Access:Customer)
  _Hide:Relate:Customer &= NEW(Hide:Relate:Customer)
  _Hide:Access:EmailLog &= NEW(Hide:Access:EmailLog)
  _Hide:Relate:EmailLog &= NEW(Hide:Relate:EmailLog)
  _Hide:Access:EmailSettings &= NEW(Hide:Access:EmailSettings)
  _Hide:Relate:EmailSettings &= NEW(Hide:Relate:EmailSettings)
  Relate:Invoice &= _Hide:Relate:Invoice
  Relate:Product &= _Hide:Relate:Product
  Relate:LineItems &= _Hide:Relate:LineItems
  Relate:Customer &= _Hide:Relate:Customer
  Relate:EmailLog &= _Hide:Relate:EmailLog
  Relate:EmailSettings &= _Hide:Relate:EmailSettings


demo_BC0:FilesInit PROCEDURE
  CODE
  _Hide:Relate:Invoice.Init
  _Hide:Relate:Product.Init
  _Hide:Relate:LineItems.Init
  _Hide:Relate:Customer.Init
  _Hide:Relate:EmailLog.Init
  _Hide:Relate:EmailSettings.Init


demo_BC0:DctKill PROCEDURE
  CODE
  _Hide:Relate:Invoice.Kill
  DISPOSE(_Hide:Relate:Invoice)
  _Hide:Relate:Product.Kill
  DISPOSE(_Hide:Relate:Product)
  _Hide:Relate:LineItems.Kill
  DISPOSE(_Hide:Relate:LineItems)
  _Hide:Relate:Customer.Kill
  DISPOSE(_Hide:Relate:Customer)
  _Hide:Relate:EmailLog.Kill
  DISPOSE(_Hide:Relate:EmailLog)
  _Hide:Relate:EmailSettings.Kill
  DISPOSE(_Hide:Relate:EmailSettings)


Hide:Relate:Invoice.Init PROCEDURE
  CODE
  _Hide:Access:Invoice.Init
  SELF.Init(Access:Invoice,1)


Hide:Access:Invoice.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= INV:Record
  SELF.FileNameValue = 'Invoice'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Invoice
  PARENT.Init
  Access:Invoice &= SELF


Hide:Access:Invoice.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Invoice &= NULL                                   ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Invoice.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Invoice,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(INV:Key,'INV:Key',1)
    SELF.AddKey(INV:CustomerKey,'INV:CustomerKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Access:Invoice.ValidateFieldServer PROCEDURE(UNSIGNED Id,BYTE HandleErrors)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.ValidateFieldServer(Id,HandleErrors)
  CASE Id
  OF 5
    GlobalErrors.SetField('INV:Terms')
    IF INSTRING(']' & INV:Terms & '[', ']0[]1[]2[', 1, 1) = 0
      ReturnValue = Level:Notify
    END
    IF ReturnValue <> Level:Benign
      IF HandleErrors
        ReturnValue = GlobalErrors.ThrowMessage(Msg:FieldNotInList,'''COD'',''7 Days'',''30 Days''')
      END
    END
  END
  RETURN ReturnValue


Hide:Relate:Invoice.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Customer)

  SELF.AddRelation(Relate:LineItems,RI:CASCADE,RI:CASCADE,LIN:InvKey)
  SELF.AddRelationLink(INV:ID,LIN:InvoiceNumber)


Hide:Relate:Invoice.Kill PROCEDURE

  CODE
  _Hide:Access:Invoice.Kill                                ! Kill the file manager
  PARENT.Kill
  Relate:Invoice &= NULL                                   ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Invoice)                            ! destroy the file manager


Hide:Relate:Product.Init PROCEDURE
  CODE
  _Hide:Access:Product.Init
  SELF.Init(Access:Product,1)


Hide:Access:Product.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= PRO:Record
  SELF.FileNameValue = 'Product'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Product
  PARENT.Init
  Access:Product &= SELF


Hide:Access:Product.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Product &= NULL                                   ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Product.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Product,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(PRO:Key,'PRO:Key',1)
    SELF.AddKey(PRO:NameKey,'PRO:NameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Product.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:LineItems,RI:None,RI:None,LIN:ProductKey)
  SELF.AddRelationLink(PRO:ID,LIN:Product)


Hide:Relate:Product.Kill PROCEDURE

  CODE
  _Hide:Access:Product.Kill                                ! Kill the file manager
  PARENT.Kill
  Relate:Product &= NULL                                   ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Product)                            ! destroy the file manager


Hide:Relate:LineItems.Init PROCEDURE
  CODE
  _Hide:Access:LineItems.Init
  SELF.Init(Access:LineItems,1)


Hide:Access:LineItems.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= LIN:Record
  SELF.FileNameValue = 'LineItems'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= LineItems
  PARENT.Init
  Access:LineItems &= SELF


Hide:Access:LineItems.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:LineItems &= NULL                                 ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:LineItems.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(LineItems,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(LIN:Key,'LIN:Key',1)
    SELF.AddKey(LIN:ProductKey,'LIN:ProductKey',0)
    SELF.AddKey(LIN:InvKey,'LIN:InvKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:LineItems.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Product)

  SELF.AddRelation(Relate:Invoice)


Hide:Relate:LineItems.Kill PROCEDURE

  CODE
  _Hide:Access:LineItems.Kill                              ! Kill the file manager
  PARENT.Kill
  Relate:LineItems &= NULL                                 ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:LineItems)                          ! destroy the file manager


Hide:Relate:Customer.Init PROCEDURE
  CODE
  _Hide:Access:Customer.Init
  SELF.Init(Access:Customer,1)


Hide:Access:Customer.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= CUS:Record
  SELF.FileNameValue = 'Customer'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Customer
  PARENT.Init
  Access:Customer &= SELF


Hide:Access:Customer.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Customer &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Customer.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Customer,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(CUS:NameKey,'CUS:NameKey',0)
    SELF.AddKey(CUS:Key,'CUS:Key',1)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Customer.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Invoice,RI:None,RI:None,INV:CustomerKey)
  SELF.AddRelationLink(CUS:ID,INV:Customer)


Hide:Relate:Customer.Kill PROCEDURE

  CODE
  _Hide:Access:Customer.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:Customer &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Customer)                           ! destroy the file manager


Hide:Relate:EmailLog.Init PROCEDURE
  CODE
  _Hide:Access:EmailLog.Init
  SELF.Init(Access:EmailLog,1)


Hide:Access:EmailLog.BindFields PROCEDURE

  CODE
  PARENT.BindFields
  BIND('emLog:MessageText',emLog:MessageText)              ! Bind memo field
  BIND('emLog:MessageHTML',emLog:MessageHTML)              ! Bind memo field


Hide:Access:EmailLog.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= emLog:Record
  SELF.FileNameValue = 'EmailLog'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= EmailLog
  PARENT.Init
  Access:EmailLog &= SELF


Hide:Access:EmailLog.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:EmailLog &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:EmailLog.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(EmailLog,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(emLog:KeyGuid,'emLog:KeyGuid',0)
    SELF.AddKey(emLog:KeyTo,'emLog:KeyTo',0)
    SELF.AddKey(emLog:KeyFrom,'emLog:KeyFrom',0)
    SELF.AddKey(emLog:KeyDate,'emLog:KeyDate',0)
    SELF.AddKey(emLog:KeyUser,'emLog:KeyUser',0)
    SELF.AddKey(emLog:KeyStatus,'emLog:KeyStatus',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:EmailLog.Kill PROCEDURE

  CODE
  _Hide:Access:EmailLog.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:EmailLog &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:EmailLog)                           ! destroy the file manager


Hide:Relate:EmailSettings.Init PROCEDURE
  CODE
  _Hide:Access:EmailSettings.Init
  SELF.Init(Access:EmailSettings,1)


Hide:Access:EmailSettings.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= emSet:Record
  SELF.FileNameValue = 'EmailSettings'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= EmailSettings
  PARENT.Init
  Access:EmailSettings &= SELF


Hide:Access:EmailSettings.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:EmailSettings &= NULL                             ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:EmailSettings.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(EmailSettings,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(emSet:KeyGuid,'emSet:KeyGuid',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:EmailSettings.Kill PROCEDURE

  CODE
  _Hide:Access:EmailSettings.Kill                          ! Kill the file manager
  PARENT.Kill
  Relate:EmailSettings &= NULL                             ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:EmailSettings)                      ! destroy the file manager

