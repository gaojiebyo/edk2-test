/** @file
 
  Copyright 2006 - 2010 Unified EFI, Inc.<BR> 
  Copyright (c) 2010, Intel Corporation. All rights reserved.<BR>
 
  This program and the accompanying materials
  are licensed and made available under the terms and conditions of the BSD License
  which accompanies this distribution.  The full text of the license may be found at 
  http://opensource.org/licenses/bsd-license.php
 
  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
 
**/
/*++

Module Name:
  
    EmsPktParse.h
    
Abstract:

    Data definition for packet parse functions

--*/

#ifndef __EMS_PARSE_H__
#define __EMS_PARSE_H__

#include "EmsTypes.h"
#include "EmsProtocols.h"
#include "EmsTclInit.h"

VOID_P
ParseTclInit (
  IN Tcl_Interp *Interp
  )
/*++

Routine Description:

  Packet parse related TCL command initialization routine

Arguments:

  Interp      - TCL intepreter.

Returns:

  None.

--*/
;

#endif
