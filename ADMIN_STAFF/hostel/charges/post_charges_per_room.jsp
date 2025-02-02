<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function SubmitPage()
{
	document.post_charge.submit();
}
function ReloadPage()
{
	document.post_charge.reloadPage.value="1";
	SubmitPage();
}
function PageAction(strAction)
{
	document.post_charge.page_action.value=strAction;
	SubmitPage();
}
function ChangeFeeName()
{
	SubmitPage();
}
function DeleteRecord(strIndex)
{
	document.post_charge.info_index.value=strIndex;
	document.post_charge.page_action.value="0";
	SubmitPage();
}
function CancelRecord()
{
	ChangeFeeName();
}
function ChangeDormLoc()
{
	document.post_charge.changeDormLoc.value="1";
	ReloadPage();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.Authentication,enrollment.HostelManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strCurSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strCurSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	boolean bolProceed = true;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
	String[] astrConvertYear = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year"};
    String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","Septmber","October","November","December"};
	String[] astrCurSchYr = null;

	if(strCurSYFrom == null || strCurSYTo == null)
	{
		bolProceed = false;
		strErrMsg = "You are logged out. Please login again.";
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-CHARGES- Post Charges","post_charges_per_room.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Hostel Management","CHARGES",request.getRemoteAddr(),
														"post_charges_per_room.jsp");
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

//end of authenticaion code.


Vector vBasicInfo = null;
Vector vPostedCharge = null;//charges posted already.
Vector vToPostCharge = null;//charges not posted yet
Vector vEditInfo = null;
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.
Vector vReservationInfo = null;
Vector vRoomInfo = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
HostelManagement HM = new HostelManagement();

if(WI.fillTextValue("page_action").compareTo("0") ==0)
{
	if(HM.operateOnPostChargesForARoom(dbOP,request,0) == null)
		strErrMsg = HM.getErrMsg();
	else
		strErrMsg = "Posted charge removed successfully.";
}
else if(WI.fillTextValue("page_action").compareTo("1") ==0)
{
	if(HM.operateOnPostChargesForARoom(dbOP,request,1) == null)
		strErrMsg = HM.getErrMsg();
	else
		strErrMsg = "Charge posted successfully.";
}
		vPostedCharge = HM.operateOnPostChargesForARoom(dbOP,request,3);
		//if(vPostedCharge == null) System.out.println(HM.getErrMsg());
		//get edit information if it is called.
		if(WI.fillTextValue("month_availed").length() > 0)//it is not first time -- so check
		{
			vToPostCharge = HM.getVariablePayableToPostForARoom(dbOP,request.getParameter("dorm_room"),request.getParameter("fee_name"),
				request.getParameter("year_availed"),request.getParameter("month_availed") );
			if(vToPostCharge == null)
				strErrMsg = HM.getErrMsg();
		}

astrCurSchYr = dbOP.getCurSchYr();
if(astrCurSchYr == null)
	strErrMsg = dbOP.getErrMsg();
if(strErrMsg == null) strErrMsg = "";
%>

<form name="post_charge" action="./post_charges_per_room.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOOL FACILITIES FEES MAINTENANCE - POST CHARGES PAGE :::: </strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"> &nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="42%">Fee name :
        <select name="fee_name" onChange="ChangeFeeName();">
          <option value="0">Select a fee</option>
          <%
strTemp = " from FA_SCH_FACILITY join FA_SCHYR on (FA_SCH_FACILITY.sy_index=FA_SCHYR.sy_index) "+
				"where is_del=0 and is_valid=1 and sy_from="+strCurSYFrom+" and sy_to="+strCurSYTo+" and facility_type=1 order by fee_name,facility_type asc";
%>
          <%=dbOP.loadCombo("SCH_FAC_FEE_INDEX","FEE_NAME",strTemp, WI.fillTextValue("fee_name"), false)%>
        </select></td>
      <td width="54%">School Year/Term<strong> : <%=strCurSYFrom%> - <%=strCurSYTo%>/
	  	<%=astrConvertTerm[Integer.parseInt(astrCurSchYr[2])]%></strong></td>
    </tr>
 <%if(WI.fillTextValue("fee_name").length() > 0){%>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
 <%}else{%>
    <tr>
      <td height="25" colspan="3"><strong>Please select a fee name type.</strong></td>
    </tr>
 <%}%>
  </table>

<%
if(WI.fillTextValue("fee_name").compareTo("0") != 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="28%">Select a room to post charge: </td>
	  <td width="68%">
        <select name="location" onChange="ChangeDormLoc();">
          <option value="0">Select a location</option>
          <%
if(WI.fillTextValue("reloadPage").length() ==0 && vReservationInfo != null)
	strTemp2 = (String)vReservationInfo.elementAt(2);
else
	strTemp2 = WI.fillTextValue("location");
strTemp = " from FA_STUD_SCHFAC_DORM_LOC where is_del=0 order by LOCATION asc";
%>
          <%=dbOP.loadCombo("LOCATION_INDEX","LOCATION",strTemp, strTemp2, false)%>
        </select>
        <%//display only if a location is selected.
if(strTemp2.length()> 0 && strTemp2.compareTo("0") != 0){%>
        <select name="dorm_room" onChange="ReloadPage();">
          <option value="0">Select a room</option>
          <%
//show all occupied  and partially occupied rooms for posting of charges.

strTemp = " from FA_STUD_SCHFAC_DORM_LAYOUT where LOCATION_INDEX="+strTemp2+
	" and is_del=0 and is_valid=1 and (room_status=1 or room_status=3)  order by room_no asc";
//System.out.println(strTemp);
if(WI.fillTextValue("reloadPage").length() ==0 && vReservationInfo != null)
	strTemp2 = (String)vReservationInfo.elementAt(4);
else
	strTemp2 = WI.fillTextValue("dorm_room");
%>
          <%=dbOP.loadCombo("DORMITORY_INDEX","ROOM_NO",strTemp, strTemp2, false)%>
        </select>
        <%}%>
		</td>
    </tr>
<%
if(strTemp2.length() > 0 && strTemp2.compareTo("0") != 0 && (WI.fillTextValue("changeDormLoc").length() ==0 || WI.fillTextValue("changeDormLoc").compareTo("0") ==0))
{
vRoomInfo = HM.getRoomInfo(dbOP, strTemp2);//System.out.println(vRoomInfo);
%>
    <tr>
      <td height="25"></td>
	  <td>Rental : <%=dbOP.mapOneToOther("FA_STUD_SCHFAC_DORM_LAYOUT","DORMITORY_INDEX",strTemp2,"rental",null)%> </td>
      <td valign="top">  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
<%}%>
	<tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%
if(vRoomInfo != null){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#CC9999">
    <tr>
      <td height="21" colspan="6"><div align="center"><strong><font size="1">OCCUPANT
          DETAIL</font></strong></div></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="12%"><div align="center"><strong><font size="1">ID NUMBER</font></strong></div></td>
      <td width="29%"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
      <td width="7%"><div align="center"><strong><font size="1">ACCOUNT TYPE</font></strong></div></td>
      <td width="40%"><div align="center"><strong><font size="1">COURSE/MAJOR
          (OR) COLLEGE/DEPT</font></strong></div></td>
      <td width="8%"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
    </tr>
<%
for( int i =5; i< vRoomInfo.size() ; ++i){%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="12%"><%=(String)vRoomInfo.elementAt(i+1)%></td>
      <td width="29%"><%=(String)vRoomInfo.elementAt(i+2)%></td>
      <td width="7%"><%=(String)vRoomInfo.elementAt(i+3)%></td>
      <td width="40%"><%=(String)vRoomInfo.elementAt(i+4)%></td>
      <td width="8%"><%=astrConvertYear[Integer.parseInt((String)vRoomInfo.elementAt(i+5))]%></td>
    </tr>
<%
i = i+8;
}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25"></td>
      <td width="46%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Charges for the month of :
        <select name="month_availed">
          <option value="0">January</option>
          <%
strTemp = WI.fillTextValue("month_availed");
for(int i=1; i< 12; ++i){
	if(strTemp.compareTo(Integer.toString(i)) ==0)
	{%>
          <option value="<%=i%>" selected><%=astrConvertMonth[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrConvertMonth[i]%></option>
          <%}
}%>
        </select> </td>
      <td width="16%">Year :
        <input name="year_availed" type="text" size="4" value="<%=WI.fillTextValue("year_availed")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="34%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td>Charges(unit) :
        <select name="variable_pay">
          <%
//only if there are any payable left to pay.
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("1") !=0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("variable_pay");

if(vToPostCharge!= null && vToPostCharge.size() > 0){
	for(int i =0; i< vToPostCharge.size() ; ++i){
	if(strTemp.compareTo((String)vToPostCharge.elementAt(i)) ==0){%>
          <option selected value="<%=(String)vToPostCharge.elementAt(i)%>"><%=(String)vToPostCharge.elementAt(i+1)%>(<%=(String)vToPostCharge.elementAt(i+2)%>)</option>
          <%}else{%>
          <option value="<%=(String)vToPostCharge.elementAt(i)%>"><%=(String)vToPostCharge.elementAt(i+1)%>(<%=(String)vToPostCharge.elementAt(i+2)%>)</option>
          <%}
	i = i+2;
	}
 }%>
        </select></td>
      <td colspan="2">Amount payable : Php
        <%
//only if there are any payable left to pay.
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("1") !=0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("amount");
if(vToPostCharge != null && vToPostCharge.size()> 0){%>
        <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <%}%>
      </td>
    </tr>
    <%
	  if(vToPostCharge != null && vToPostCharge.size() > 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Particulars <font size="1">(consumption readings):
        <input name="textfield" type="text" size="56" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </font></td>
    </tr>
<%}if(vToPostCharge != null && vToPostCharge.size() ==0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <strong>All charges are posted. </strong></td>
    </tr>
    <%}%>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(iAccessLevel > 1 && vToPostCharge != null && vToPostCharge.size()  > 0){%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" height="25" colspan="3">
        <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0"></a><font size="1">click
        to save entry</font>
		</td>
    </tr>
<%}//if iAccessLevel > 1%>
  </table>
<%
if(vPostedCharge  != null && vPostedCharge.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">LIST
          OF CHARGES AND AMOUNT PAYABLES FOR <%=astrConvertMonth[Integer.parseInt(request.getParameter("month_availed"))]%>
		  &nbsp;<%=request.getParameter("year_availed")%></div></td>
    </tr>
    <tr > <td width="4%" >&nbsp;</td>
      <td width="35%" height="25" ><strong><font size="1">CHARGES</font></strong></td>
      <td width="27%" ><strong><font size="1">UNIT</font></strong></td>
      <td width="24%" ><strong><font size="1">AMOUNT PAYABLE</font></strong></td>
      <td width="10%" ><strong><font size="1">DELETE</font></strong></td>
    </tr>
<%
float fTotalPayable = 0;
for(int i=0; i< vPostedCharge.size() ; ++i){
fTotalPayable += Float.parseFloat((String)vPostedCharge.elementAt(i+3));
%>
    <tr>
      <td width="4%" ></td>
	  <td height="25"><%=(String)vPostedCharge.elementAt(i+1)%></td>
      <td height="25"><%=(String)vPostedCharge.elementAt(i+2)%></td>
      <td height="25"><%=CommonUtil.formatFloat((String)vPostedCharge.elementAt(i+3),true)%></td>
      <td>
<%if(iAccessLevel > 1){%>
	  <a href='javascript:DeleteRecord("<%=(String)vPostedCharge.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>
	  </td>
    </tr>
<%
i = i+3;
}%>

    <tr >
      <td height="25" colspan="2"><div align="right">TOTAL AMOUNT PAYABLE :</div></td>
      <td  colspan="2" height="25"> <strong>&nbsp; Php <%=CommonUtil.formatFloat(fTotalPayable,true)%></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<%		}//if vPostedCharge != null
	}//if vRoomInfo is not null
}//if fee name is not selected.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="sy_from" value="<%=astrCurSchYr[0]%>"%>
<input type="hidden" name="sy_to" value="<%=astrCurSchYr[1]%>"%>
<input type="hidden" name="semester" value="<%=astrCurSchYr[2]%>"%>


<input type="hidden" name="changeDormLoc" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
