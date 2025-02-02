<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave, hr.HRLeaveSetting"%>

<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;


	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
	TD{
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;	
	}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>
</head> 
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	boolean bolMyHome = false;

//add security hehol.

	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"leave_apply.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult = null;
Vector vEmpRec = null;
Vector vEditResult = null;
boolean bNoError = false;
boolean bolSetEdit = false;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
int iIndexOf = 0;
double[] adLeaveType = {0d, 0d};

HRInfoLeave hrPx = new HRInfoLeave();
HRLeaveSetting hrSetting = new HRLeaveSetting();

Vector vSignatories = null;
String strGovLeaveType = null;
String strLeaveReason = null;

// meaning sick leave/vacation/maternity
// if any of the three... don't go to others
String strIsGovLeave = "";
String strLeaveName = null;
String strLeaveCase = null;
String strLeaveSpecific = null;

int iAction =  -1;

if (WI.fillTextValue("emp_id").length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vEmpRec == null){
		strErrMsg = authentication.getErrMsg();
	}
}

vEditResult = hrPx.operateOnLeaveApplication(dbOP, request, 3);
if (vEditResult == null){
	strErrMsg = hrPx.getErrMsg();
}else{
	vSignatories = hrSetting.operateOnLeaveSignatories(dbOP, request, 4);
	
	strGovLeaveType = WI.getStrValue((String)vEditResult.elementAt(58));
	strLeaveReason = WI.getStrValue((String)vEditResult.elementAt(23));

	strLeaveName = WI.getStrValue((String)vEditResult.elementAt(42),"Leave without Pay");
	strLeaveName = strLeaveName.toUpperCase();
	if(strLeaveName.indexOf("LEAVE") == -1)
		strLeaveName = strLeaveName + " LEAVE";

	if(strLeaveName.indexOf("VACATION") != -1 ||
		strGovLeaveType.equals("1")){
		if(strLeaveReason.toLowerCase().indexOf("employment") != -1){
			strIsGovLeave = "0";
			strLeaveName = "&nbsp;";
		}else{
			strIsGovLeave = "1";
			if(strLeaveName.indexOf("VACATION") != -1)
				strLeaveName = strLeaveReason;
		}
	}else if (strLeaveName.indexOf("MATERNITY") != -1){
		strIsGovLeave = "2";
	}else if (strLeaveName.indexOf("SICK") != -1 ||
		strGovLeaveType.equals("2")){
		strIsGovLeave = "3";
		if(strLeaveName.indexOf("SICK") != -1)
			strLeaveName = strLeaveReason;			
	}

	strIsGovLeave = WI.getStrValue(strIsGovLeave, "1");
 }

//Vector vAllowedLeave = hrPx.getAllowedLeave(dbOP, request);
Vector vAllowedLeave = hrPx.getAvailableLeaveForSemNew(dbOP, request);

String[] astrConvertAMPM={" AM"," PM"};
String[] astrCurrentStatus ={"Disapproved", "Approved", "Pending/On-process",
							 "Requires Approval of Vice-President", 
							 "Requires Approval of President"};
String strSem = null;
double dTemp = 0d;
Vector vLeaveBreakDown = hrPx.getGovLeaveBreakdown(dbOP, request);
 %>
<body onLoad="window.print()">
<% if (strErrMsg != null && strErrMsg.length() > 0) { %>
<%=strErrMsg%>

<%}else if (vEmpRec !=null && vEmpRec.size() > 0 && vEditResult != null && vEditResult.size() > 0){ %>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF">
    <td width="103%" height="25" colspan="3" valign="middle">
	CSC Form Np. 6<br>
  Revised 1984  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25" colspan="3" align="center" valign="middle" class="thinborderBottom"><strong><font size="2">APPLICATION 
      FOR LEAVE</font></strong></td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td height="25" colspan="3" align="center" valign="middle"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="40%" height="23">1. OFFICE/ AGENCY </td>
        <td width="10%">2. NAME </td>
        <td width="15%">(Last)</td>
        <td width="20%">(First)</td>
        <td width="15%">(Middle)</td>
      </tr>
      <tr>
				<%
					if((String)vEmpRec.elementAt(13) == null)
						strTemp = WI.getStrValue((String)vEmpRec.elementAt(14));
					else{
						strTemp =WI.getStrValue((String)vEmpRec.elementAt(13));
						if((String)vEmpRec.elementAt(14) != null)
							 strTemp += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
					}
				%>			
        <td height="26" valign="bottom" class="thinborderBottom"><strong><%=strTemp%></strong></td>
        <td valign="bottom" class="thinborderBottom">&nbsp;</td>
        <td valign="bottom" class="thinborderBottom"><strong><%=WI.getStrValue((String)vEmpRec.elementAt(3))%></strong></td>
        <td valign="bottom" class="thinborderBottom"><strong><%=WI.getStrValue((String)vEmpRec.elementAt(1))%></strong></td>
        <td valign="bottom" class="thinborderBottom"><strong><%=WI.getStrValue((String)vEmpRec.elementAt(2))%></strong></td>
      </tr>
    </table></td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td colspan="3" align="center" valign="middle" class="thinborderBottom"><table width="100%" height="51" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="24" valign="top">3. DATE OF FILING </td>
        <td valign="top">4. POSITION</td>
        <td valign="top">5. SALARY (Monthly) </td>
      </tr>
      <tr>
        <td height="24" valign="bottom"><strong><%=WI.getStrValue((String)vEditResult.elementAt(3))%><br>
        </strong></td>
        <td valign="bottom"><strong><%=WI.getStrValue((String)vEmpRec.elementAt(15))%></strong></td>
        <td valign="bottom">&nbsp;</td>
      </tr>
    </table></td>
  </tr>
</table>
        
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="37" colspan="2" align="center" valign="bottom" bgcolor="#FFFFFF" class="thinborderBottom"> 
         
    <strong><font size="2">6. DETAILS OF APPLICATION</font></strong></td>
  </tr>
  <tr>
    <td height="25" valign="top" bgcolor="#FFFFFF">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td colspan="6">6.a) TYPE OF LEAVE</td>
        </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="5" align="center" nowrap>&nbsp;</td>
        </tr>
      <tr>
        <td width="2%" height="20">&nbsp;</td>
				<%
				//System.out.println("strGovLeaveType " + strGovLeaveType);
					if(strGovLeaveType.equals("1"))
						strTemp = "X";
					else
						strTemp = "&nbsp;"; 
				%>
        <td width="8%" align="center" nowrap>(<strong><%=strTemp%></strong>)</td>
        <td colspan="4">Vacation</td>
        </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td>&nbsp;</td>
				<%				
				if(strIsGovLeave.equals("0"))
					strTemp = "X";
				else
					strTemp = "&nbsp;&nbsp;";
				%>
        <td width="8%" align="center" nowrap>(<strong><%=strTemp%></strong>)</td>
        <td width="42%">To seek Employment</td>
        <td width="24%">&nbsp;</td>
        <td width="16%">&nbsp;</td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td>&nbsp;</td>
        <%
					strTemp = "&nbsp;&nbsp;";
					if(strIsGovLeave.equals("1"))
						strTemp = "X";
				  %>
        <td align="center">(<strong><%=strTemp%></strong>)</td>
        <td>Others (specify)</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
          <%
					strTemp = "&nbsp;";
					if(strIsGovLeave.equals("1"))
						strTemp = strLeaveName;
				  %>
         <td colspan="3" class="thinborderBottom">&nbsp;<%=strTemp%></td>
        </tr>
      <tr>
        <td height="20">&nbsp;</td>
				<%
					if(strGovLeaveType.equals("2"))
						strTemp = "X";
					else
						strTemp = "&nbsp;"; 
				%>				
        <td align="center">(<strong><%=strTemp%></strong>)</td>				
        <td colspan="4">Sick</td>
        </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td>&nbsp;</td>
        <%
					strTemp = "&nbsp;&nbsp;";
					if(strIsGovLeave.equals("2"))
						strTemp = "X";
				  %>		
        <td align="center">(<strong><%=strTemp%></strong>)</td>
        <td>Maternity</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td>&nbsp;</td>
        <%
					strTemp = "&nbsp;&nbsp;";
					if(strIsGovLeave.equals("3"))
						strTemp = "X";
				  %>				
        <td align="center">(<strong><%=strTemp%></strong>)</td>
        <td>Others(specify)</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
          <%
					strTemp = "&nbsp;";
					if(strIsGovLeave.equals("3"))
						strTemp = strLeaveName;
				  %>				
        <td colspan="3" class="thinborderBottom">&nbsp;<%=strTemp%></td>
        </tr>
    </table></td>
    <td width="48%" valign="top" bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td colspan="3">6.b) WHERE LEAVE WILL BE SPENT</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td width="7%" height="20">&nbsp;</td>
        <td colspan="2">(1) IN CASE OF VACATION LEAVE </td>
      </tr>
			<%
			 if (vEditResult != null){
					strLeaveCase = WI.getStrValue((String)vEditResult.elementAt(63));
					strLeaveSpecific = WI.getStrValue((String)vEditResult.elementAt(64));
				}
				
				strLeaveCase = WI.getStrValue(strLeaveCase);
				strLeaveSpecific = WI.getStrValue(strLeaveSpecific);			
			%>			
      <tr>
        <td height="20">&nbsp;</td>
        <%
				if(strLeaveCase.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;&nbsp;";				
				%>
        <td width="8%" nowrap>(<strong><%=strTemp2%></strong>)</td>
        <td>Within the Philippines</td>
        </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <%
				if(strLeaveCase.equals("1")){
					strTemp2 = "X";
					strTemp = strLeaveSpecific;
				}else{
					strTemp2 = "&nbsp;&nbsp;";				
					strTemp = "&nbsp;";
				}
				%>				
        <td>(<strong><%=strTemp2%></strong>)</td>
        <td width="85%">Abroad (specify) </td>
        </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td>&nbsp;</td>
        <td class="thinborderBottom">&nbsp;<%=strTemp%></td>
        </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td colspan="2">(2) IN CASE OF SICK LEAVE </td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <%
				if(strLeaveCase.equals("2")){
					strTemp2 = "X";
					strTemp = strLeaveSpecific;
				}else{
					strTemp2 = "&nbsp;&nbsp;";				
					strTemp = "&nbsp;";			
				}
				%>				
        <td valign="top">(<strong><%=strTemp2%></strong>)</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>In Hospital(Specify)</td>
          </tr>
          <tr>
            <td height="19" class="thinborderBottom">&nbsp;<%=strTemp%></td>
          </tr>
        </table></td>
        </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <%
				if(strLeaveCase.equals("3")){
					strTemp2 = "X";
					strTemp = strLeaveSpecific;
				}else{
					strTemp2 = "&nbsp;&nbsp;";				
					strTemp = "";			
				}			
				%>				
        <td valign="top">(<strong><%=strTemp2%></strong>)</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>Out Patient (Specify)</td>
          </tr>
          <tr>
            <td height="19" class="thinborderBottom">&nbsp;<%=strTemp%></td>
          </tr>
        </table></td>
        </tr>
      
    </table></td>
  </tr>
  <tr>
    <td height="14" colspan="2" valign="top" bgcolor="#FFFFFF"></td>
  </tr>
  <tr>
    <td height="25" valign="top" bgcolor="#FFFFFF" class="thinborderBottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="7%">(6.c)</td>
        <td colspan="3">NUMBER of WORKING DAYS APPLIED </td>
        </tr>
      <tr>
        <td>&nbsp;</td>
        <td width="20%" align="right"><strong>
          <%	
			strTemp = WI.getStrValue((String)vEditResult.elementAt(22),"0");
			if(((String)vEditResult.elementAt(46)).equals("1"))
				strTemp += " hour(s)";
			else
				strTemp += " day(s)";
	/*	
	if (strTemp.equals("0")) 
		strTemp = ""; 
	else
		strTemp += " day(s)";

	if (!WI.getStrValue((String)vEditResult.elementAt(21),"0").equals("0")){
		if (strTemp.length() != 0)
			strTemp += " / ";
		strTemp +=(String)vEditResult.elementAt(21) + " hour(s)";
	}
	*/
%>
          <%=strTemp%> &nbsp;</strong></td>
        <td width="73%" colspan="2">working day/s  </td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="3">INCLUSIVE DATES : </td>
        </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="3" align="center" class="thinborderBottom"><strong><%=(String)vEditResult.elementAt(10)%>&nbsp;
            <% 						
						strTemp =  WI.getStrValue((String)vEditResult.elementAt(11));						
	if (strTemp.length() > 0) {
		strTemp = "(" + strTemp;
		if (WI.getStrValue((String)vEditResult.elementAt(12), "00").length() < 2){
			strTemp += ":0" + WI.getStrValue((String)vEditResult.elementAt(12), "00");
		}else{
			strTemp += ":" + WI.getStrValue((String)vEditResult.elementAt(12), "00");
		}			
		strTemp += astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(13),"0"))]
		 + ")";
	}
%>
            <%=strTemp%>
            <% strTemp = WI.getStrValue((String)vEditResult.elementAt(14));
	  if (strTemp.length() > 0) 
	  		strTemp = "&nbsp;&nbsp; - &nbsp;&nbsp;" + strTemp;
	  %>
            <%=strTemp%>
            <%  strTemp =  WI.getStrValue((String)vEditResult.elementAt(15));
	if (strTemp.length() > 0) {
		strTemp = "(" + strTemp;
		if (WI.getStrValue((String)vEditResult.elementAt(16), "00").length() < 2){
			strTemp += ":0" + WI.getStrValue((String)vEditResult.elementAt(16), "00");
		}else{
			strTemp += ":" + WI.getStrValue((String)vEditResult.elementAt(16), "00");
		}

		strTemp += astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(17),"0"))]
		 + ")";
	}
%>
          <%=strTemp%></strong></td>
        </tr>
    </table></td>
    <td bgcolor="#FFFFFF" class="thinborderBottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="8%">(6.d)</td>
        <td colspan="4">COMMUTATION</td>
        </tr>
      <tr>
        <td>&nbsp;</td>
				<%
				 if (vEditResult != null){
						strTemp = WI.getStrValue((String)vEditResult.elementAt(59));
				 }
				 if(strTemp.equals("1"))
					 	strTemp2 = "X";
				 else
					 	strTemp2 = "&nbsp;&nbsp;";
				%>
        <td width="8%">(<strong><%=strTemp2%></strong>)</td>
        <td width="36%">Requested</td>
				<%
				 if(strTemp.equals("0"))
					 	strTemp2 = "X";
				 else
					 	strTemp2 = "&nbsp;&nbsp;";
				%>					
        <td width="8%">(<strong><%=strTemp2%></strong>)</td>
        <td width="40%">Not Requested </td>
        </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="4">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="4" class="thinborderBottom">&nbsp;</td>
      </tr>
      <tr>
        <td height="18">&nbsp;</td>
        <td colspan="4" align="center" class="thinborderBottom">&nbsp;</td>
      </tr>
      <tr>
        <td height="18">&nbsp;</td>
        <td colspan="4" align="center">Signature of Applicant)</td>
        </tr>
    </table></td>
  </tr>
  <tr>
    <td height="25" valign="bottom" bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="8%" rowspan="2" nowrap>7. a) </td>
        <td colspan="2">CERTIFICATION OF LEAVE CREDITS</td>
        </tr>
      <tr>
        <td width="11%">as of </td>
        <td width="81%" class="thinborderBottom"><strong><%=WI.getTodaysDate(1)%></strong></td>
      </tr>
    </table></td>
    <td rowspan="2" valign="top" bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td colspan="4">7.b) RECOMMENDATION </td>
        </tr>
      <tr>
        <td width="7%" height="22">&nbsp;</td>
				<%
				 if (vEditResult != null){
						strTemp = WI.getStrValue((String)vEditResult.elementAt(60));
				 }
				 if(strTemp.equals("1"))
					 	strTemp2 = "X";
				 else
					 	strTemp2 = "&nbsp;&nbsp;";
				%>			
        <td width="8%" nowrap>(<strong><%=strTemp2%></strong>)</td>
          <td width="32%">Approval</td>
          <td width="53%">&nbsp;</td>
        </tr>
      <tr>
        <td height="22">&nbsp;</td>
				<%
				 if(strTemp.equals("0"))
					 	strTemp2 = "X";
				 else
					 	strTemp2 = "&nbsp;&nbsp;";
				%>				
        <td>(<strong><%=strTemp2%></strong>)</td>
          <td>Disapproval due to </td>
					<%
					 if (vEditResult != null)
							strTemp = WI.getStrValue((String)vEditResult.elementAt(61));
					%>					
          <td class="thinborderBottom">&nbsp;<%=strTemp%></td>
        </tr>
    </table></td>
  </tr>
  <tr>
    <td height="25" valign="bottom" bgcolor="#FFFFFF">
		<%
			if(vAllowedLeave != null && vAllowedLeave.size() > 0){
				for(int i = 0 ; i < vAllowedLeave.size(); i+=15) {
					strTemp = (String)vAllowedLeave.elementAt(i+4);
					/*
					iIndexOf = strTemp.toUpperCase().indexOf("VACATION");
					if(iIndexOf != -1){
						adLeaveType[0] = Double.parseDouble((String)vAllowedLeave.elementAt(i+2));
					}else{
						iIndexOf = strTemp.toUpperCase().indexOf("SICK");
						if(iIndexOf != -1)
							adLeaveType[1] = Double.parseDouble((String)vAllowedLeave.elementAt(i+2));
					}
					*/
					
					if(strTemp.toUpperCase().equals("VACATION") || strTemp.toUpperCase().equals("VACATION LEAVE"))
						adLeaveType[0] = Double.parseDouble((String)vAllowedLeave.elementAt(i+2));
					else if(strTemp.toUpperCase().equals("SICK") || strTemp.toUpperCase().equals("SICK LEAVE"))
						adLeaveType[1] = Double.parseDouble((String)vAllowedLeave.elementAt(i+2));
				}
			}
		%>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="33%" height="22" align="center" class="thinborderBottom">Vacation</td>
        <td width="33%" align="center" class="thinborder">Sick</td>
        <td width="34%" align="center" class="thinborder">TOTAL</td>
      </tr>
      <tr>
        <td height="22" align="center" class="thinborderBottom"><strong><%=CommonUtil.formatFloat(adLeaveType[0], 3)%></strong></td>
        <td align="center" class="thinborder"><strong><%=CommonUtil.formatFloat(adLeaveType[1], 3)%></strong></td>
        <td align="center" class="thinborder"><strong><%=CommonUtil.formatFloat(adLeaveType[0] + adLeaveType[1], 3)%></strong></td>
      </tr>
      <tr>
        <td height="22" align="center">Days</td>
        <td align="center">Days</td>
        <td align="center">Days</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td height="25" valign="bottom" bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="20%">&nbsp;</td>
				<%
				/*
				strTemp = "&nbsp;";
				strTemp2 = "&nbsp;";
				if(vSignatories != null && vSignatories.size() > 0){
					iIndexOf = vSignatories.indexOf(new Long(100));
					if(iIndexOf != -1){
						strTemp = (String)vSignatories.elementAt(iIndexOf+3);
						strTemp2 = (String)vSignatories.elementAt(iIndexOf+2);
					}
				}
				*/
 				 strTemp = null;
				 if (vEditResult != null)
						strTemp = WI.getStrValue((String)vEditResult.elementAt(65));
					strTemp = WI.getStrValue(strTemp);
				%>
        <td width="60%" align="center" class="thinborderBottom"><strong><%=strTemp.toUpperCase()%></strong></td>
        <td width="20%">&nbsp;</td>
      </tr>
      <tr>
				<%
				strTemp = null;
				 if (vEditResult != null)
						strTemp = WI.getStrValue((String)vEditResult.elementAt(66));				
				%>
        <td colspan="3" align="center"><%=WI.getStrValue(strTemp, "(Authorized Official)")%></td>
        </tr>
      
    </table></td>
  </tr>
  <tr>
    <td height="25" valign="bottom" bgcolor="#FFFFFF" class="thinborderBottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      
      <tr>
        <td width="15%">&nbsp;</td>
				<%
				//strTemp = "&nbsp;";
				//strTemp2 = "&nbsp;";
				//if(vSignatories != null && vSignatories.size() > 0){
				//		iIndexOf = vSignatories.indexOf(new Long(101));
				//		if(iIndexOf != -1){
				//			strTemp = (String)vSignatories.elementAt(iIndexOf+3);
				//			strTemp2 = (String)vSignatories.elementAt(iIndexOf+2);
				//		}
				//	}
 				 strTemp = null;
				 if (vEditResult != null)
						strTemp = WI.getStrValue((String)vEditResult.elementAt(67));
					strTemp = WI.getStrValue(strTemp);
				%>				
        <td width="70%" align="center" class="thinborderBottom"><strong><%=strTemp.toUpperCase()%></strong></td>
        <td width="15%">&nbsp;</td>
      </tr>
      <tr>
				<%
 				 strTemp = null;
				 if (vEditResult != null)
						strTemp = WI.getStrValue((String)vEditResult.elementAt(68));
				%>
        <td colspan="3" align="center"><%=WI.getStrValue(strTemp)%></td>
        </tr>
      <tr>
        <td colspan="3" align="center">&nbsp;</td>
      </tr>
    </table></td>
    <td bgcolor="#FFFFFF" class="thinborderBottom">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" valign="bottom" bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="56%">7. C) APPROVED FOR : </td>
        <td width="44%">&nbsp;</td>
      </tr>
			<%
				strTemp = "--";
				if(vLeaveBreakDown != null && vLeaveBreakDown.size() > 0){
					dTemp =  Double.parseDouble((String)vLeaveBreakDown.elementAt(3));
					if(dTemp > 0d){
						strTemp = dTemp + " hr(s)";
					}
					
					dTemp =  Double.parseDouble((String)vLeaveBreakDown.elementAt(2));
					if(dTemp > 0d)
						strTemp = dTemp + " day(s) ";
				}
			%>
      <tr>			
        <td class="thinborderBottom">&nbsp;<%=strTemp%></td>
        <td>&nbsp;days with pay  </td>
      </tr>
      <tr>
			<%
				strTemp = "--";
				if(vLeaveBreakDown != null && vLeaveBreakDown.size() > 0){
					dTemp =  Double.parseDouble((String)vLeaveBreakDown.elementAt(1));
					if(dTemp > 0d){
						strTemp = dTemp + " hr(s)";
					}
					
					dTemp =  Double.parseDouble((String)vLeaveBreakDown.elementAt(0));
					if(dTemp > 0d)
						strTemp = dTemp + " day(s) ";
				}
			%>			
        <td class="thinborderBottom">&nbsp;<%=strTemp%></td>
        <td> &nbsp;days without pay</td>
      </tr>
      <tr>
			<%
				strTemp = "";
				if(vLeaveBreakDown != null && vLeaveBreakDown.size() > 0){
					strTemp = (String)vLeaveBreakDown.elementAt(4);
					dTemp =  Double.parseDouble(strTemp);
					if(dTemp == 0d)				
						strTemp = "--";
				}
			%>			
        <td class="thinborderBottom">&nbsp;<%=strTemp%></td>
        <td>&nbsp;other (specify) </td>
      </tr>
    </table></td>
    <td valign="top" bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="56%">7. D) DISAPPROVED DUE TO :</td>
      </tr>
      <tr>
				<%
				 if (vEditResult != null)
						strTemp = WI.getStrValue((String)vEditResult.elementAt(62));
				%>					
        <td class="thinborderBottom">&nbsp;<%=strTemp%></td>
        </tr>
    </table></td>
  </tr>
  <tr>
    <td height="25" colspan="2" valign="bottom" bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="30%" height="44">&nbsp;</td>
        <td width="40%" align="center" class="thinborderBottom">&nbsp;</td>
        <td width="30%">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td align="center">(SIGNATURE)</td>
        <td>&nbsp;</td>
      </tr>
				<%
				//strTemp = "&nbsp;";
				//strTemp2 = "&nbsp;";
				//if(vSignatories != null && vSignatories.size() > 0){
				//		iIndexOf = vSignatories.indexOf(new Long(102));
				//		if(iIndexOf != -1){
				//			strTemp = (String)vSignatories.elementAt(iIndexOf+3);
				//			strTemp2 = (String)vSignatories.elementAt(iIndexOf+2);
				//		}
				//	}
				%>			
				<%
 				 strTemp = null;
				 if (vEditResult != null)
						strTemp = WI.getStrValue((String)vEditResult.elementAt(69));
					strTemp = WI.getStrValue(strTemp);
				%>
      <tr>
        <td height="28">&nbsp;</td>
        <td align="center" valign="bottom"><strong><%=strTemp.toUpperCase()%></strong></td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
				<%
 				 strTemp = null;
				 if (vEditResult != null)
						strTemp = WI.getStrValue((String)vEditResult.elementAt(70));
					strTemp = WI.getStrValue(strTemp);
				%>				
        <td align="center" class="thinborderBottom"><%=strTemp%></td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td align="center">(AUTHORIZED OFFICIAL)</td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
  </tr>
</table>
<% } %>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</body>
</html>
<%
	dbOP.cleanUP();
%>
