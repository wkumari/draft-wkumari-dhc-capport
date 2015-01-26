**Important:** Read CONTRIBUTING.md before submitting feedback or contributing
```




Network Working Group                                          W. Kumari
Internet-Draft                                                    Google
Intended status: Informational                            O. Gudmundsson
Expires: July 30, 2015                                     Shinkuro Inc.
                                                             P. Ebersman
                                                                 Comcast
                                                                S. Sheng
                                                                   ICANN
                                                        January 26, 2015


               Captive-Portal identification in DHCP / RA
                      draft-wkumari-dhc-capport-08

Abstract

   In many environments offering short-term or temporary Internet access
   (such as coffee shops), it is common to start new connections in a
   captive portal mode.  This highly restricts what the customer can do
   until the customer has authenticated.

   This document describes a DHCP option (and an RA extension) to inform
   clients that they are behind some sort of captive portal device, and
   that they will need to authenticate to get Internet Access.

Status of This Memo

   This Internet-Draft is submitted in full conformance with the
   provisions of BCP 78 and BCP 79.

   Internet-Drafts are working documents of the Internet Engineering
   Task Force (IETF).  Note that other groups may also distribute
   working documents as Internet-Drafts.  The list of current Internet-
   Drafts is at http://datatracker.ietf.org/drafts/current/.

   Internet-Drafts are draft documents valid for a maximum of six months
   and may be updated, replaced, or obsoleted by other documents at any
   time.  It is inappropriate to use Internet-Drafts as reference
   material or to cite them other than as "work in progress."

   This Internet-Draft will expire on July 30, 2015.

Copyright Notice

   Copyright (c) 2015 IETF Trust and the persons identified as the
   document authors.  All rights reserved.





Kumari, et al.            Expires July 30, 2015                 [Page 1]

Internet-Draft             DHCP Captive-Portal              January 2015


   This document is subject to BCP 78 and the IETF Trust's Legal
   Provisions Relating to IETF Documents
   (http://trustee.ietf.org/license-info) in effect on the date of
   publication of this document.  Please review these documents
   carefully, as they describe your rights and restrictions with respect
   to this document.  Code Components extracted from this document must
   include Simplified BSD License text as described in Section 4.e of
   the Trust Legal Provisions and are provided without warranty as
   described in the Simplified BSD License.

Table of Contents

   1.  Introduction  . . . . . . . . . . . . . . . . . . . . . . . .   2
     1.1.  Requirements notation . . . . . . . . . . . . . . . . . .   3
   2.  Background  . . . . . . . . . . . . . . . . . . . . . . . . .   3
     2.1.  DNS Redirection . . . . . . . . . . . . . . . . . . . . .   4
     2.2.  HTTP Redirection  . . . . . . . . . . . . . . . . . . . .   4
     2.3.  IP Hijacking  . . . . . . . . . . . . . . . . . . . . . .   4
   3.  The Captive-Portal DHCP Option  . . . . . . . . . . . . . . .   4
   4.  The Captive-Portal RA Option  . . . . . . . . . . . . . . . .   5
   5.  Use of the Captive-Portal Option  . . . . . . . . . . . . . .   6
   6.  IANA Considerations . . . . . . . . . . . . . . . . . . . . .   7
   7.  Security Considerations . . . . . . . . . . . . . . . . . . .   8
   8.  Acknowledgements  . . . . . . . . . . . . . . . . . . . . . .   8
   9.  Normative References  . . . . . . . . . . . . . . . . . . . .   9
   Appendix A.  Changes / Author Notes.  . . . . . . . . . . . . . .   9
   Authors' Addresses  . . . . . . . . . . . . . . . . . . . . . . .  10

1.  Introduction

   In many environments, users need to connect to a captive portal
   device and agree to an acceptable use policy and / or provide billing
   information before they can access the Internet.

   Many devices perform DNS, HHTP, and / or IP hijacks in order to
   present the user with the captive portal web page.  These kludgy
   workarounds and techniques resemble attacks that DNSSEC and TLS are
   intended to protect against.  This document describes a DHCP option
   (Captive Portal) and an IPv6 Router Advertisement (RA) extension that
   informs clients that they are behind a captive portal device and how
   to contact it.

   This document neither condones nor condemns the use of captive
   portals; instead, it recognises that their apparent necessity, and
   attempts to improve the user experience.






Kumari, et al.            Expires July 30, 2015                 [Page 2]

Internet-Draft             DHCP Captive-Portal              January 2015


1.1.  Requirements notation

   The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
   "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
   document are to be interpreted as described in [RFC2119].

2.  Background

   Some ISPs implement a captive portal (CP) - a system that intercepts
   user requests and redirects them to an interstitial login page - in
   order to require the user accept an Acceptable Use Policy (AUP),
   provide billing information, or otherwise authenticate a user prior
   to allowing them to access the Internet.

   Captive portals intercept and redirect user requests in a number of
   ways, including:

   o  DNS Redirection

   o  IP Redirection

   o  HTTP Redirection

   o  Restricted scope addresses

   o  Traffic blocking (until the user is authenticated)

   In order to ensure that the user is unable to access the Internet
   until they have satisfied the requirements, captive portals usually
   implement IP based filters, or place the user into a restricted VLAN
   (or restricted IP range) until after they have been authorized /
   satisfied.

   These techniques are very similar to attacks that protocols (such as
   VPNs, DNSSEC, TLS) are designed to protect against.  The interaction
   of these protections and the interception leads to poor user
   experiences, such as long timeouts, inability to reach the captive
   portal web page, etc.  The interception may also leak user
   information (for example, if the captive portal intercepts and logs
   an HTTP Cookie, or URL of the form http://fred:password@example.com).
   The user is often unaware of what is causing the issue (their browser
   appears to hang, saying something like "Downloading Proxy Script", or
   simply "The Internet doesn't work"), and they become frustrated.
   This may result in them not purchasing the Internet access provided
   by the captive portal.  The connectivity attempts may also facilitate
   OS fingerprinting even before a client attempts to connect to the
   portal itself.




Kumari, et al.            Expires July 30, 2015                 [Page 3]

Internet-Draft             DHCP Captive-Portal              January 2015


2.1.  DNS Redirection

   The CP either intercepts all DNS traffic or advertises itself (for
   example using DHCP) as the recursive server for the network.  Until
   the user has authenticated to the captive portal, the CP responds to
   all DNS requests listing the address of its web portal.  Once the
   user has authenticated, the CP returns the "correct" addresses.

   This technique has many shortcomings.  It fails if the client is
   performing DNSSEC validation, is running their own resolver, is using
   a VPN, or already has the DNS information cached.

2.2.  HTTP Redirection

   In this implementation, the CP acts like a transparent HTTP proxy;
   but when it sees an HTTP request from an unauthenticated client using
   HTTP/1.0, it intercepts the request and responds with an HTTP status
   code 302 to redirect the client to the Captive Portal Login.  If the
   client is using HTTP/1.1, we respond with a status code 303 See
   Other.

   This technique has a number of issues, including:

   o  It fails if the user is only using HTTPS.

   o  It exposes various private user information, such as HTTP Cookies,
      etc.

   o  It doesn't work if the client has a VPN and / or proxies their web
      traffic to an external web proxy.

2.3.  IP Hijacking

   In this scenario, the captive portal intercepts connections to any IP
   address.  It spoofs the destination IP address and "pretends" to be
   whatever the user tried to access.

   This technique has issues similar to the HTTP solution, but may also
   break other protocols, and may expose more of the user's private
   information.

3.  The Captive-Portal DHCP Option

   The Captive Portal DHCP Option (TBA1) informs the DHCP client that it
   is behind a captive portal and provides the URI to access an
   authentication page.  This is primarily intended to improve the user
   experience; for the foreseeable future (until such time that most




Kumari, et al.            Expires July 30, 2015                 [Page 4]

Internet-Draft             DHCP Captive-Portal              January 2015


   systems implement this technique) captive portals will still need to
   implement the interception techniques to serve legacy clients.

   The format of the DHCP Captive-Portal DHCP option is shown below.

     Code    Len          Data
     +------+------+------+------+------+--   --+-----+
     | code |  len |  URI                  ...        |
     +------+------+------+------+------+--   --+-----+

   o  Code: The Captive-Portal DHCP Option (TBA1 for DHCPv4, TBA2 for
      DHCPv6)

   o  Len: The length, in octets of the URI.

   o  URI: The URI of the authentication page that the user should
      connect to.

   In order to avoid having to perform DNS interception, the URI SHOULD
   contain an IPv4 address literal.

   For cases requiring SSL/TLS (collection of billing information for
   example), the IP literal can redirect to a URI containing a DNS name.

   [ED NOTE: Using an address literal is less than ideal, but better
   than the alternatives.  Recommending a DNS name means that the CP
   would need to allow DNS from unauthenticated clients (as we don't
   want to force users to use the CP's provided DNS) and some users
   would use this to DNS Tunnel out.  This would make the CP admin block
   external recursives).]

4.  The Captive-Portal RA Option

   [Ed: I'm far from an RA expert.  I think there are only 8 bits for
   Type, is it worth burning an option code on this?  I have also
   specified that the option length should padded to multiples of 8 byte
   to better align with the examples I've seen.  Is this required /
   preferred, or is smaller RAs better? ]

   This section describes the Captive-Portal Router Advertisement
   option.










Kumari, et al.            Expires July 30, 2015                 [Page 5]

Internet-Draft             DHCP Captive-Portal              January 2015


    0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |     Type      |     Length    |              URI              .
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               .
      .                                                               .
      .                                                               .
      .                                                               .
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
               Figure 2: Captive-Portal RA Option Format

   Type  TBA3

   Length  8-bit unsigned integer.  The length of the option (including
      the Type and Length fields) in units of 8 bytes.

   URI  The URI of the authentication page that the user should connect
      to.  For the reasons described above, the implementer might want
      to use an IP address literal instead of a DNS name.  This should
      be padded with NULL (0x0) to make the total option length
      (including the Type and Length fields) a multiple of 8 bytes.

5.  Use of the Captive-Portal Option

   [ED NOTE: This option provides notice to the OS / User applications
   that there is a CP.  Because of differences in UI design between
   Operating Systems, the exact behaviour by OS and Applications is left
   to the OS vendor/Application Developer.]

   The purpose of the Captive-Portal Option is to inform the operating
   system and applications that they are behind a captive portal type
   device and will need to authenticate before getting network access
   (and how to reach the authentication page).  What is done with this
   information is left up to the operating system and application
   vendors.  This document provides a very high level example of what
   could be done with this information.

   Many operating systems / applications already include a "connectivity
   test" to determine if they are behind a captive portal (for example,
   attempting to fetch a specific URL and looking for a specific string
   (such as "Success").  These tests sometimes fail or take a long time
   to determine when they are behind a CP, but are usually effective for
   determining that the captive portal has been satisfied.  These tests
   will continue to be needed, because there is currently no definitive
   signal from the captive portal that it has been satisfied. [ Editor
   note: It may be useful to write another document that specifies how a
   client can determine that it has passed the CP.  This document could
   also contain advice to implmentors on only intercepting actually



Kumari, et al.            Expires July 30, 2015                 [Page 6]

Internet-Draft             DHCP Captive-Portal              January 2015


   needed ports, how to advertise that the CP needs to be statisfied
   *again*, etc.  This should not be done in this document though. ] The
   connectivity test may also need to be used if the captive portal
   times out the user session and needs the user to re-authenticate.
   The operating system may still find the information about the captive
   portal URI useful in this case.

   When the device is informed that it is behind a captive portal it
   should:

   1.  Not initiate new IP connections until the CP has been satisfied
       (other than those to the captive portal browser session and
       connectivity checks).  Existing connections should be quiesced
       (this will happen more often than some expect -- for example, the
       user purchases 1 hour of Internet at a cafe and stays there for 3
       hours -- this will "interrupt" the user a few times).

   2.  Present a dialog box to the user informing them that they are
       behind a captive portal and ask if they wish to proceed.

   3.  If the user elects to proceed, the device should initiate a
       connection to the captive portal login page using a web browser
       configured with a separate cookie store, and without a proxy
       server.  If there is a VPN in place, this connection should be
       made outside of the VPN and the user should be informed that
       connection is outside the VPN.  Some captive portals send the
       user a cookie when they authenticate (so that the user can re-
       authenticate more easily in the future) - the browser should keep
       these CP cookies separate from other cookies.

   4.  Once the user has authenticated, normal IP connectivity should
       resume.  The CP success page should contain a string, e.g
       "CP_SATISFIED."  The OS can then use this string to provide
       further information to the user.

   5.  The device should (using an OS dependent method) expose to the
       user / user applications that they have connected though a
       captive portal (for example by creating a file in /proc/net/
       containing the interface and captive portal URI).  This should
       continue until the network changes, or a new DHCP message without
       the CP is received.

6.  IANA Considerations

   This document defines DHCPv4 Captive-Portal option which requires
   assignment of DHCPv4 option code TBA1 assigned from "Bootp and DHCP
   options" registry (http://www.iana.org/assignments/ bootp-dhcp-
   parameters/bootp-dhcp-parameters.xml), as specified in [RFC2939].



Kumari, et al.            Expires July 30, 2015                 [Page 7]

Internet-Draft             DHCP Captive-Portal              January 2015


   IANA is also requested to assign an IPv6 RA Option Type code (TBA3)
   from the "IPv6 Neighbor Discovery Option Formats" registry.  Thanks
   IANA!

7.  Security Considerations

   An attacker with the ability to inject DHCP messages could include
   this option and so force users to contact an address of his choosing.
   As an attacker with this capability could simply list himself as the
   default gateway (and so intercept all the victim's traffic), this
   does not provide them with significantly more capabilities.  Fake
   DHCP servers / fake RAs are currently a security concern - this
   doesn't make them any better or worse.

   Devices and systems that automatically connect to an open network
   could potentially be tracked using the techniques described in this
   document (forcing the user to continually authenticate, or exposing
   their browser fingerprint.)  However, similar tracking can already be
   performed with the standard captive portal mechanisms, so this
   technique does not give the attackers more capabilities.

   By simplifying the interaction with the captive portal systems, and
   doing away with the need for interception, we think that users will
   be less likely to disable useful security safeguards like DNSSEC
   validation, VPNs, etc.  In addition, because the system knows that it
   is behind a captive portal, it can know not to send cookies,
   credentials, etc.  Redirection to a portal where TLS can be used
   without hijacking can ameliorate some of the implications of
   connecting to a potentially malicious captive portal.

8.  Acknowledgements

   The primary author has discussed this idea with a number of folk, and
   asked them to assist by becoming co-authors.  Unfortunately he has
   forgotten who many of them were; if you were one of them, I
   apologize.

   Thanks to Vint Cerf for the initial idea / asking me to write this.
   Thanks to Wes George for supplying the IPv6 text.  Thanks to Lorenzo
   and Erik for the V6 RA kick in the pants.

   Thanks to Fred Baker, Asbjorn Tonnesen and Ted Lemon for detailed
   review and comments.  Also great thanks to Joel Jaeggli for providing
   feedback and text.







Kumari, et al.            Expires July 30, 2015                 [Page 8]

Internet-Draft             DHCP Captive-Portal              January 2015


9.  Normative References

   [RFC2119]  Bradner, S., "Key words for use in RFCs to Indicate
              Requirement Levels", BCP 14, RFC 2119, March 1997.

Appendix A.  Changes / Author Notes.

   [RFC Editor: Please remove this section before publication ]

   From 07 to 08:

   o  Incorporated comments from Ted Lemon.  Made the document much
      shorter.

   From 06 to 07:

   o  Incoroprated a bunch of comments from Asbjorn Tonnesen

   o  Clarified that this document is only for the DHCP bits, not
      everything.

   o  CP's *can* do HTTP redirects to DNS banes, as long as they allow
      access to all needed services.

   From 05 to 06:

   o  Integrated comments from Joel, as below

   o  Better introduction text, around the "kludgy hacks" section.

   o  Better "neither condones nor condems" text

   o  Fingerprint text.

   o  Some discussions on the v4 literal stuff.

   o  More Security Consideration text.

   From 04 to 05:

   o  Integrated comments, primarily from Fred Baker.

   From 03 to 04:

   o  Some text cleanup for readability.

   o  Some disclaimers about it working better on initial connection
      versus CP timeout.



Kumari, et al.            Expires July 30, 2015                 [Page 9]

Internet-Draft             DHCP Captive-Portal              January 2015


   o  Some more text explaining that CP interception is
      indistinguishable from an attack.

   o  Connectivity Check test.

   o  Posting just before the draft cutoff - "I love deadlines.  I love
      the whooshing noise they make as they go by." -- Douglas Adams,
      The Salmon of Doubt

   From -02 to 03:

   o  Removed the DHCPv6 stuff (as suggested / requested by Erik Kline)

   o  Simplified / cleaned up text (I'm inclined to waffle on, then trim
      the fluff)

   o  This was written on a United flight with in-flight WiFi -
      unfortunately I couldn't use it because their CP was borked. :-P

   From -01 to 02:

   o  Added the IPv6 RA stuff.

   From -00 to -01:

   o  Many nits and editorial changes.

   o  Whole bunch of extra text and review from Wes George on v6.

   From initial to -00.

   o  Nothing changed in the template!

Authors' Addresses

   Warren Kumari
   Google
   1600 Amphitheatre Parkway
   Mountain View, CA  94043
   US

   Email: warren@kumari.net









Kumari, et al.            Expires July 30, 2015                [Page 10]

Internet-Draft             DHCP Captive-Portal              January 2015


   Olafur Gudmundsson
   Shinkuro Inc.
   4922 Fairmont Av, Suite 250
   Bethesda, MD  20814
   USA

   Email: ogud@ogud.com


   Paul Ebersman
   Comcast

   Email: ebersman-ietf@dragon.net


   Steve Sheng
   Internet Corporation for Assigned Names and Numbers
   12025 Waterfront Drive, Suite 300
   Los Angeles  90094
   United States of America

   Phone: +1.310.301.5800
   Email: steve.sheng@icann.org




























Kumari, et al.            Expires July 30, 2015                [Page 11]
```
