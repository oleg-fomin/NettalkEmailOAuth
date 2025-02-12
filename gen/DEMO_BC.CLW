  MEMBER('demo.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('demo_BC0.CLW')
demo_BC0:DctInit             PROCEDURE
demo_BC0:DctKill             PROCEDURE
demo_BC0:FilesInit           PROCEDURE
    END
  END

DctInit PROCEDURE
  CODE
  demo_BC0:DctInit
  demo_BC0:FilesInit


DctKill PROCEDURE
  CODE
  demo_BC0:DctKill

