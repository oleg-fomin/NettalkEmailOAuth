# NettalkEmailOAuth project
## Overview
This public Github repo contains Clarion sources of **NettalkEmailSendOAuth** Class and sample application demonstrating capability to send Email using modern authentication protocol (OAuth2). This is a free contribution to Clarion community.
## Privacy policy, terms of service and license agreement
Sample application requires user authentiation with Microsoft and/or Google with given concent to send email on behalf of respective user account. Since the app requests user data, please read and agree with the following documents before using the software.
* [Privacy policy](https://oleg-fomin.github.io/NettalkEmailOAuth/privacy.html)
* [Terms of service](https://oleg-fomin.github.io/NettalkEmailOAuth/tos.html)
* [License agreement](https://oleg-fomin.github.io/NettalkEmailOAuth/LICENSE)
## Requirements
* Clarion 10 (or higher) from [SoftVelocity](https://www.softvelocity.com/)
* [CapeSoft NetTalk](https://www.capesoft.com/accessories/netsp.htm) (Desktop, Server or Apps edition)
## NettalkEmailSendOAuth class description
**NettalkEmailSendOAuth** class inherits all the functionality of it's base class **NettalkEmailSend**. So, the classes can be used interchangeably. Both classes support SMTP, inherited **NettalkEmailSendOAuth** class has additional capability to send email using REST API. REST endpoints, SMTP server, port, SSL and all the OAuth provider parameters are stored in JSON configuration file loaded using either local path or remote http(s) link specified. Remote coniguration is useful because all the parameters, including OAuth secrets, are subject to change over time. 

**NettalkEmailSendOAuth** class definition files below should be installed into Clarion\libsrc, Clarion\accessory\libsrc or other folder scanned for ABC classes.
* [\libsrc\NetEmailOauth.inc](https://github.com/oleg-fomin/NettalkEmailOAuth/blob/main/libsrc/NetEmailOauth.inc)
* [\libsrc\NetEmailOauth.clw](https://github.com/oleg-fomin/NettalkEmailOAuth/blob/main/libsrc/NetEmailOauth.clw)
 
![NetEmailSendOauth3](https://github.com/user-attachments/assets/44495f9f-9bb8-49c9-8b10-e8049c2b484e)
## Sample application
Sample application provided is a modified copy of Nettalk example application typically installed as **Capesoft\nettalk\Email\Demo\demo.app**.

Modifications are as follows.
* **UpdateEmailSettings** procedure WINDOW definition changed by adding WIZARD attribte to the SHEET with new TAB('OAuth') control added for displaying OAuth related settings.

  ![NetEmailSendOauth5](https://github.com/user-attachments/assets/39d90765-2c6c-4ff5-a8b0-7bde897cd10c)
  
  ![NetEmailSendOauth1](https://github.com/user-attachments/assets/59af9a38-6e13-439a-841c-6ad2aefa32ac)

  When 'Use Modern Authentication Protocol (OAuth2)' checkbox is clear you just hit 'Next' button and see all the usual SMTP email settings as before. Otherwise, you can select 'OAuth provider' from the drop-down list and choose between 'REST API' and 'SMTP' options. 'From Address:' field is common and 'Next' button turns into 'Ok'. So, hit 'Ok' button and you are done with Email Settings.
* **Invoice.dct (dctx)** changed by adding two new fields to **EmailSetup** table.

  ![NetEmailSendOauth8](https://github.com/user-attachments/assets/c30a3e2a-f12f-4fb7-84a1-10763c6d062f)
* **OAuthLogin** procedure added by importing TXA.
  
  ![NetEmailSendOauth2](https://github.com/user-attachments/assets/f75e76a7-8af4-4f55-8f1f-be7110f16fa8)
* **SendEmail** procedure Base class changed from **NettalkEmailSend** to **NettalkEmailSendOAuth** in template prompts.

  ![NetEmailSendOauth4](https://github.com/user-attachments/assets/8856bd7a-17d1-4011-891e-b7b3f7731500)
* **SendEmail** procedure embedded code changed to make use of new **emSet:OAuthProvider**, **emSet:OAuthSendMode** fields from **EmailSettings** table.

  ![NetEmailSendOauth7](https://github.com/user-attachments/assets/e0cf5052-9a83-4384-bbd9-56d7c355226e)
* **SendEmail** procedure embedded code changed inside **ThisSendEmail.OAuthLogin** virtual method to make use of new **OAuthLogin** procedure added (imported from TXA) earlier.

   ![NetEmailSendOauth9](https://github.com/user-attachments/assets/dac3c797-9c26-46d3-8b1b-2519e50b4186)

That's it. Now modified Nettalk email demo application supports OAuth2. Using such simple steps you can OAuth upgrade your own [Clarion](https://www.softvelocity.com/) appliation(s) sending email with [CapeSoft Nettalk](https://www.capesoft.com/accessories/netsp.htm).

Copyright 2025 Oleg Fomin <oleg@fomin.info>
