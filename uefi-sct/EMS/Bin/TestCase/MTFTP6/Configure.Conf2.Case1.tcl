# 
#  Copyright 2006 - 2010 Unified EFI, Inc.<BR> 
#  Copyright (c) 2010, Intel Corporation. All rights reserved.<BR>
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
CaseGuid          021DDF81-4D35-4b10-AA99-E39F61057396
CaseName          Configure.Conf2.Case1
CaseCategory      MTFTP6
CaseDescription   {Test Configure Conformance of MTFTP6 - Invoke Configure()\
                   when ServerIp is not a valid unicast IPv6 address.  \
                   EFI_INVALID_PARAMETER should be returned.}
################################################################################

Include MTFTP6/include/Mtftp6.inc.tcl

#
# Begin log ...
#
BeginLog

BeginScope _MTFTP6_CONFIGURE_CONFORMANCE2_CASE1_

#
# Parameter Definition
# R_ represents "Remote EFI Side Parameter"
# L_ represents "Local OS Side Parameter"
#
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
# check point: Call Configure function when ServerIp is \
#              not a valid unicast IPv6 address.\
#              EFI_INVALID_PARAMETER should be returned.
#
EFI_MTFTP6_CONFIG_DATA      R_Mtftp6ConfigData
SetIpv6Address    R_Mtftp6ConfigData.StationIp         "::" 
SetVar            R_Mtftp6ConfigData.LocalPort         0
SetIpv6Address    R_Mtftp6ConfigData.ServerIp          "ff02::1"
SetVar            R_Mtftp6ConfigData.InitialServerPort 0
SetVar            R_Mtftp6ConfigData.TryCount          3
SetVar            R_Mtftp6ConfigData.TimeoutValue      3

Mtftp6->Configure "&@R_Mtftp6ConfigData, &@R_Status"
GetAck
set assert [VerifyReturnStatus R_Status $EFI_INVALID_PARAMETER]
RecordAssertion $assert $Mtftp6ConfigureConf2AssertionGuid001                  \
                "Mtftp6.Configure -conf- Call Configure when ServerIP isn't a valid IPv6 address"  \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_INVALID_PARAMETER"

# Set ServerIp "::"
SetIpv6Address    R_Mtftp6ConfigData.ServerIp          "::"

Mtftp6->Configure "&@R_Mtftp6ConfigData, &@R_Status"
GetAck
set assert [VerifyReturnStatus R_Status $EFI_INVALID_PARAMETER]
RecordAssertion $assert $Mtftp6ConfigureConf2AssertionGuid002                  \
                "Mtftp6.Configure -conf- Call Configure when ServerIP isn't a valid IPv6 address"  \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_INVALID_PARAMETER"

#
# Destroy Child 
#
Mtftp6ServiceBinding->DestroyChild "@R_Handle, &@R_Status"
GetAck
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $GenericAssertionGuid                  \
                "Mtftp6SB.DestroyChild - Destroy Child "                  \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"

EndScope _MTFTP6_CONFIGURE_CONFORMANCE2_CASE1_

#
# End Log
#
EndLog