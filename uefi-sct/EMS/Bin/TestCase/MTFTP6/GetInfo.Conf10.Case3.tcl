# 
#  Copyright 2006 - 2011 Unified EFI, Inc.<BR> 
#  Copyright (c) 2010 - 2011, Intel Corporation. All rights reserved.<BR>
# 
#  This program and the accompanying materials
#  are licensed and made available under the terms and conditions of the BSD License
#  which accompanies this distribution.  The full text of the license may be found at 
#  http://opensource.org/licenses/bsd-license.php
# 
#  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
#  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
# 
################################################################################
CaseLevel         CONFORMANCE
CaseAttribute     AUTO
CaseVerboseLevel  DEFAULT
set reportfile    report.csv

#
# test case Name, category, description, GUID...
#
CaseGuid          E77E9C63-CC6F-40b0-9ED9-9FE6B063767D
CaseName          GetInfo.Conf10.Case3
CaseCategory      MTFTP6
CaseDescription   {Test GetInfo Conformance of MTFTP6 - Invoke GetInfo() \
                   when a ICMPv6 host unreachable packet received from the other side. 
                   EFI_HOST_UNREACHABLE should be returned.}
################################################################################

proc CleanUpEutEnvironment {} {

#
# Destroy Child 
#
Mtftp6ServiceBinding->DestroyChild "@R_Handle, &@R_Status"
GetAck

EUTClose

DestroyPacket
EndCapture
EndScope _MTFTP6_GETINFO_CONFORMANCE10_CASE3_

#
# End Log
#
EndLog
}

Include MTFTP6/include/Mtftp6.inc.tcl

#
# Begin log ...
#
BeginLog

BeginScope _MTFTP6_GETINFO_CONFORMANCE10_CASE3_

EUTSetup

UINTN                            R_Status
UINTN                            R_Handle

Mtftp6ServiceBinding->CreateChild "&@R_Handle, &@R_Status"
GetAck
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $GenericAssertionGuid                   \
                "Mtftp6SB.CreateChild - Create Child "                    \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"
SetVar     [subst $ENTS_CUR_CHILD]  @R_Handle

#
# Initialization on ENTS side.
#
LocalEther  $DEF_OS_MAC_ADDR
RemoteEther $DEF_EUT_MAC_ADDR
LocalIPv6   $DEF_OS_IP_ADDR
RemoteIPv6  $DEF_EUT_IP_ADDR

#
# Check Point: Call Configure function with valid parameters.\
#              EFI_SUCCESS should be returned.
#
EFI_MTFTP6_CONFIG_DATA      R_Mtftp6ConfigData
SetIpv6Address    R_Mtftp6ConfigData.StationIp         "2002::4321" 
SetVar            R_Mtftp6ConfigData.LocalPort         1780
SetIpv6Address    R_Mtftp6ConfigData.ServerIp          "2002::2"
SetVar            R_Mtftp6ConfigData.InitialServerPort 0
SetVar            R_Mtftp6ConfigData.TryCount          3
SetVar            R_Mtftp6ConfigData.TimeoutValue      3

Mtftp6->Configure "&@R_Mtftp6ConfigData, &@R_Status"
GetAck
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $GenericAssertionGuid                 \
                "Mtftp6.Configure -conf- Call Configure with valid parameters"  \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"

#
# check point: Call GetInfo function when a ICMPv6 host unreachable packet received \
#              from the other side.EFI_HOST_UNREACHABLE should be returned.
#
CHAR8                            R_Filename(20)
SetVar R_Filename                "Shell.efi"

UINT8                            R_OptionCount
SetVar R_OptionCount             1

EFI_MTFTP6_OPTION                R_OptionList(8)

CHAR8                            R_OptionStr0(10)
CHAR8                            R_ValueStr0(10)
SetVar R_OptionStr0                          "tsize"
SetVar R_ValueStr0                           "0"
SetVar R_OptionList(0).OptionStr             &@R_OptionStr0
SetVar R_OptionList(0).ValueStr              &@R_ValueStr0

UINT32                           R_PacketLength
POINTER                          R_Packet

#
# Start capture
#
set L_Filter "ether proto 0x86dd"
StartCapture CCB $L_Filter

Mtftp6->GetInfo "NULL, &@R_Filename, NULL, @R_OptionCount, \
                                     &@R_OptionList, &@R_PacketLength, &@R_Packet, &@R_Status"

ReceiveCcbPacket CCB Mtftp6Packet 10
if { ${CCB.received} == 0} {
#
# If have not captured the packet. Fail
#
GetAck
set assert fail
RecordAssertion $assert $GenericAssertionGuid    \
                  "Mtftp6.GetInfo -conf- No packet received."

CleanUpEutEnvironment
return
}

#
# If have captured the packet. Send back an ICMPv6 host unreachable packet.
#
ParsePacket Mtftp6Packet -t IPv6 -IPv6_src IPV6Src -IPv6_dst IPV6Dst
SendPacket [Icmp6Unreach $IPV6Src $IPV6Dst 0x03]
GetAck

set assert [VerifyReturnStatus R_Status $EFI_HOST_UNREACHABLE]
RecordAssertion $assert $Mtftp6GetInfoConf10AssertionGuid003                         \
                "Mtftp6.GetInfo -conf- Call GetInfo when a ICMPv6 host unreachable packet received from the other side."  \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_HOST_UNREACHABLE"

#
# Check Point: clean up the environment
#
CleanUpEutEnvironment